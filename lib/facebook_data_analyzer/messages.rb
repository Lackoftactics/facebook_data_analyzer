# frozen_string_literal: true

module FacebookDataAnalyzer
  class Messages < Analyzeable
    include FacebookDataAnalyzer::ExportViewsMixin

    # conversation: {#conversation: {#sender: [messages],
    #                                 message_count: count,
    #                                 word_count: count,
    #                                 character_count: count,
    #                                 xd_count: count} ...}
    # conversation_words {#conversation: {#word: count...} ...}
    # sender: {#name: {messages: [messages],
    #                 message_count: count,
    #                 word_count: count,
    #                 character_count: count,
    #                 xd_count: count} ...}
    GROUP_BY = [:conversation, :conversation_words, :sender].freeze

    # date, month, year, day_of_week, hour: {#unit: count ...}
    # weekend: {weekend: count,
    #           weekday: count}
    # year_hour: {#year - #hour: count ...}
    # word: {#word: count ...}
    COUNT_BY = [:date, :month, :year, :day_of_week, :hour, :weekend, :year_hour, :word].freeze

    EXPORTS = [:conversation_ranking, :most_talkative, :message_statistics, :vocabulary_statistics, :popular_conversation_words,
              :most_words_in_common].freeze

    def initialize(catalog:, options: {})
      @verbose = options.fetch(:verbose)
      @catalog = catalog
      @directory = "#{catalog}/messages"
      @file_pattern = '*.html'
      @messages = []

      super(parallel: options.fetch(:parallel))
    end

    def me
      @me ||= Nokogiri::HTML(File.open("#{@catalog}/index.htm")).title.split(' - Profile')[0].to_sym
    end

    def analyze
      Dir.chdir(@directory) do
        messages_files = Dir.glob(@file_pattern)

        # This block will be skipped if all message files have already been parsed
        ::Parallel.each(messages_files, in_processes: @processes_supported, progress: 'Parsing Messages') do |file|
          conversation_messages = extract_messages(file: file).map do |message|
            { sender: message.sender,
              conversation: message.conversation,
              date_sent: message.date_sent.to_s,
              content: message.content }
          end

          File.open("_#{file}.json", 'w') do |json|
            json.write(conversation_messages.to_json)
          end
        end unless @verbose || (Dir.glob('_*.json').count == messages_files.count)

        semaphore = Mutex.new
        parsed_message_files = Dir.glob('_*.json')
        ::Parallel.each(parsed_message_files, in_threads: @threads_supported, progress: 'Analyzing Messages') do |json_file|
          json_message_array = JSON.parse(File.read(json_file))
          messages = json_message_array.map do |message|
            Message.build(json_message: message)
          end

          semaphore.synchronize do
            messages.each do |message|
              @messages << message
              group(analyzeable: message)
              count(analyzeable: message)
            end
          end
        end
      end
    end

    def conversation_stats_for_sender(conversation:, sender:)
      counts = Hash.new(0)
      sender_messages = @grouped_by[:conversation][conversation][sender]

      return counts if sender_messages.nil?

      sender_messages.each do |message|
        message.content_counts.each do |count_by, count|
          counts[count_by] += count
        end
      end

      counts
    end

    def count_by_sender(sender:)
      count_by = Hash.new {|hash, key| hash[key] = Hash.new(0)}
      sender_messages = @grouped_by[:sender][sender][:messages]

      sender_messages.each do |message|
        count(analyzeable: message, aggregate_hash: count_by)
      end

      count_by
    end

    def count_by_conversation_sender(conversation:, sender:)
      count_by = Hash.new {|hash, key| hash[key] = Hash.new(0)}
      sender_messages = @grouped_by[:conversation][conversation][sender]

      return count_by if sender_messages.nil?

      sender_messages.each do |message|
        count(analyzeable: message, aggregate_hash: count_by)
      end

      count_by
    end

    def most_popular_polish_words
      @popular_polish_words ||= begin
        polish_words = Set.new
        File.open('most_popular_polish_words.txt').map do |line|
          polish_word = line.split(' ')[0].downcase
          polish_words.add(polish_word) unless polish_word.nil?
        end

        polish_words
      end
    end

    def most_popular_english_words
      @popular_english_words ||= begin
        english_words = Set.new
        File.open('most_popular_english_words.txt').map do |line|
          english_word = line.split(' ')[0].downcase
          english_words.add(english_word) unless english_word.nil?
        end

        english_words
      end
    end

    private

    def extract_messages(file:)
      content = File.open(file)
      doc = Nokogiri::HTML(content)
      conversation_name = doc.title.split('Conversation with ')[1]

      return [] if conversation_name.nil?

      conversation = doc.at_css('.thread').children
      conversation_senders = []
      conversation_contents = []
      messages = []

      conversation.each do |node|
        if node.name == 'div' && node['class'] == 'message'
          conversation_senders << node
        elsif node.name == 'p'
          # There are empty <p> as padding around images
          conversation_contents << node unless node.children.count == 0
        end
      end

      conversation_senders.zip(conversation_contents).each do |conversation_node|
        # Expects each slice to consist of the div with sender info and the p with content
        next if conversation_node.count != 2
        message = Message.parse(sender_info: conversation_node[0], content: conversation_node[1], conversation: conversation_name)

        next if message.sender.nil?

        messages << message
      end

      messages
    end
  end
end

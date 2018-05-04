class Messages < Analyzeable
  # conversation: {#conversation: {#sender: [messages],
  #                                 message_count: count,
  #                                 word_count: count,
  #                                 character_count: count,
  #                                 xd_count: count} ...}
  # sender: {#name: {messages: [messages],
  #                 message_count: count,
  #                 word_count: count,
  #                 character_count: count,
  #                 xd_count: count} ...}
  GROUP_BY = [:conversation, :sender].freeze

  # date, month, year, day_of_week, hour: {#unit: count ...}
  # weekend: {weekend: count,
  #           weekday: count}
  # year_hour: {#year - #hour: count ...}
  # word: {#word: count ...}
  COUNT_BY = [:date, :month, :year, :day_of_week, :hour, :weekend, :year_hour, :word].freeze

  def initialize(catalog:, parallel:)
    @catalog = catalog
    @directory = "#{catalog}/messages"
    @file_pattern = '*.html'
    @messages = []

    super(parallel: parallel)
  end

  def me
    @me ||= Nokogiri::HTML(File.open("#{@catalog}/index.htm")).title.split(' - Profile')[0].to_sym
  end

  def analyze
    Dir.chdir(@directory) do
      messages_files = Dir.glob(@file_pattern)

      # This block will be skipped if all message files have already been parsed
      Parallel.each(messages_files, in_processes: @processes_supported, progress: "Parsing Messages") do |file|
        conversation_messages = extract_messages(file: file).map do |message|
          {sender: message.sender,
           conversation:message.conversation,
           date_sent: message.date_sent.to_s,
           content: message.content}
        end

        File.open("_#{file}.json", 'w') do |json|
          json.write(conversation_messages.to_json)
        end
      end unless ENV['DEBUG'] # || (Dir.glob('_*.json').count != messages_files.count)

      semaphore = Mutex.new
      parsed_message_files = Dir.glob('_*.json')
      Parallel.each(parsed_message_files, in_threads: @threads_supported, progress: "Analyzing Messages") do |json_file|
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

  def export(package:)
    friends_ranking_sheet(package: package)
    message_statistics_sheet(package: package)
    vocabulary_statistics(package: package)
  end

  def conversation_counts_for_sender(conversation:, sender:)
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
    count_by = Hash.new { |hash, key| hash[key] = Hash.new(0) }
    sender_messages = @grouped_by[:sender][sender][:messages]

    sender_messages.each do |message|
      count(analyzeable: message, aggregate_hash: count_by)
    end

    count_by
  end

  private

  def friends_ranking_sheet(package:)
    package.workbook.add_worksheet(name: 'Friends ranking') do |sheet|
      sheet.add_row ['Friends ranking']
      sheet.add_row ['Rank', 'Friend/Conversation name', 'total count', 'your messages count', 'other messages count',
                     'your characters count', 'other characters count', 'your words', 'other words']

      ranking = @grouped_by[:conversation].sort_by { |_name, data| data[:message_count] }.reverse
      rank = 1
      ranking.each do |convo_name, convo_data|
        my_counts = conversation_counts_for_sender(conversation: convo_name, sender: me)

        sheet.add_row [rank, convo_name, convo_data[:message_count],
                       my_counts[:message_count], convo_data[:message_count] - my_counts[:message_count],
                       my_counts[:character_count], convo_data[:character_count] - my_counts[:character_count],
                       my_counts[:word_count], convo_data[:word_count] - my_counts[:word_count]]
        rank += 1
      end
    end
  end

  def message_statistics_sheet(package:)
    package.workbook.add_worksheet(name: 'My message statistics') do |sheet|
      my_messages_details = @grouped_by[:sender][me]
      my_message_count_by = count_by_sender(sender: me)
      sheet.add_row ['My message statistics']
      sheet.add_row ["You sent in total #{my_messages_details[:message_count]} messages"]
      sheet.add_row ["You used #{my_messages_details[:character_count]} characters in total"]
      sheet.add_row ["You also used #{my_messages_details[:word_count]} words in total"]
      sheet.add_row ["You also happened to use xD #{my_messages_details[:xd_count]} times"]
      sheet.add_row ['']

      sheet.add_row ['Messaging by month']
      sheet.add_row ['Month', 'total # of messages', '# of my messages']
      @counted_by[:month].sort_by { |_month, count| count }.each do |month, count|
        sheet.add_row [month, count, my_message_count_by[:month][month]]
      end

      sheet.add_row ['Messaging by year']
      sheet.add_row ['Year', 'total # of messages', '# of my messages']
      @counted_by[:year].sort_by { |year, _count| year }.each do |year, count|
        sheet.add_row [year, count, my_message_count_by[:year][year]]
      end

      sheet.add_row ['Messaging by day of week']
      sheet.add_row ['Day of week', 'total # of messages', '# of my messages']
      @counted_by[:day_of_week].sort_by { |_day, count| count }.reverse.each do |day, count|
        sheet.add_row [day, count, my_message_count_by[:day_of_week][day]]
      end

      sheet.add_row ['Messaging on week days vs. weekend']
      sheet.add_row ['Type of day', 'total # of messages', '# of my messages']
      @counted_by[:weekend].each do |type, count|
        sheet.add_row [type, count, my_message_count_by[:weekend][type]]
      end

      sheet.add_row ['Breakdown of messages by hour']
      sheet.add_row ['Hour', 'total # of messages', '# of my messages']
      @counted_by[:hour].sort_by { |hour, _count| hour }.each do |hour, count|
        sheet.add_row [hour, count, my_message_count_by[:hour][hour]]
      end

      sheet.add_row ['Breakdown of messages by hour and year']
      sheet.add_row ['Year and hour', 'total # of messages', '# of my messages']
      @counted_by[:year_hour].sort_by { |year_hour, _count| y, h = year_hour.split(' - '); "#{y}0".to_i + h.to_i }.each do |year_hour, count|
        sheet.add_row [year_hour, count, my_message_count_by[:year_hour][year_hour]]
      end

      sheet.add_row ['Most busy messaging days']
      sheet.add_row ['Date', 'total # of messages', '# of my messages']
      @counted_by[:date].sort_by { |_date, count| count }.reverse.each do |date, count|
        sheet.add_row [date, count, my_message_count_by[:date][date]]
      end
    end
  end

  def vocabulary_statistics(package:)
    my_words = count_by_sender(sender: me)[:word]
    my_word_count = @grouped_by[:sender][me][:word_count]

    package.workbook.add_worksheet(name: 'Vocabulary statistics') do |sheet|
      sheet.add_row ['Vocabulary statistics']
      sheet.add_row ["You used #{my_words.length} unique words and #{my_word_count} words in total"]

      most_popular_polish_words.each do |word|
        my_words.delete(word)
      end

      most_popular_english_words.each do |word|
        my_words.delete(word)
      end

      sheet.add_row ['This are cleaned results without most common english words']
      sheet.add_row %w[Rank Word Occurrences]

      words_ranked = my_words.sort_by { |_word, count| count }.reverse[0..999]
      rank = 1
      words_ranked.each do |word, count|
        sheet.add_row [rank, word, count]
        rank += 1
      end
    end
  end

  def most_popular_polish_words
    @popular_polish_words ||= begin
      File.open('most_popular_polish_words.txt').map do |line|
        line.split(' ')[0].downcase
      end.compact
    end
  end

  def most_popular_english_words
    @popular_english_words ||= begin
      File.open('most_popular_english_words.txt').map do |line|
        line.split(' ')[0].downcase
      end.compact
    end
  end

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
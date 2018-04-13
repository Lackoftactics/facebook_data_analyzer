class Messages
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

  def initialize(catalog:)
    @catalog = catalog
    @directory = "#{catalog}/messages"
    @file_pattern = '*.html'
    @messages = []

    # Grouped by is weird and needs a hash for each GROUP_BY, hash for each unique group, and hash for attributes
    @grouped_by = Hash.new do |by_group, key|
      by_group[key] = Hash.new do |group_name, attribute|
        group_name[attribute] = Hash.new(nil)
      end
    end
    @counted_by = Hash.new { |hash, key| hash[key] = Hash.new(0) }
  end

  def me
    @me ||= Nokogiri::HTML(File.open("#{@catalog}/index.htm")).title.split(' - Profile')[0].to_sym
  end

  def analyze
    Dir.chdir(@directory) do
      messages_files = Dir.glob(@file_pattern)

      messages_files.each do |file|
        content = File.open(file)

        doc = Nokogiri::HTML(content)
        conversation_name = doc.title.split('Conversation with ')[1]
        puts "Analyzing conversation with: #{conversation_name}"

        conversation = doc.css('.thread').children
        conversation_senders = conversation.css('div.message')
        conversation_contents = conversation.css('p')
        html_messages = conversation_senders.zip(conversation_contents)

        html_messages.each do |conversation_node|
          # Expects each slice to consist of the div with sender info and the p with content
          next if conversation_node.count != 2 || conversation_node.any? { |node| node.text == "" }
          message_details = Message.parse(sender_info: conversation_node[0], content: conversation_node[1])
          message = Message.new(sender: message_details[:sender],
                                conversation: conversation_name,
                                date_sent: message_details[:date_sent],
                                content: message_details[:content]
                                )
          @messages << message
          group!(analyzeable: message)
          count!(analyzeable: message)
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

  def word_counts_for_sender(sender:)
    words = Hash.new(0)
    sender_messages = @grouped_by[:sender][sender][:messages]

    return words if sender_messages.nil?

    sender_messages.each do |message|
      message.words.map(&:to_sym).each do |word|
        words[word] += 1
      end
    end

    words
  end

  private

  def group!(analyzeable:)
    GROUP_BY.each do |attribute|
      grouping_method = "group_by_#{attribute}".to_sym

      if analyzeable.respond_to?(grouping_method)
        grouped_analyzeable = analyzeable.send(grouping_method)

        grouped_analyzeable.each do |group, group_attributes|
          group_attributes.each do |group_attribute_key, group_attribute_value|
            current_grouping = @grouped_by[attribute][group][group_attribute_key]
            if current_grouping.nil?
              @grouped_by[attribute][group][group_attribute_key] = group_attribute_value
            else
              @grouped_by[attribute][group][group_attribute_key] += group_attribute_value
            end
          end
        end
      end
    end
  end

  def count!(analyzeable:)
    COUNT_BY.each do |attribute|
      counting_method = "count_by_#{attribute}".to_sym

      if analyzeable.respond_to?(counting_method)
        countables = analyzeable.send(counting_method)

        countables.each do |countable|
          @counted_by[attribute][countable] += 1
        end
      end
    end
  end

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
      sheet.add_row ['My message statistics']
      sheet.add_row ["You sent in total #{my_messages_details[:message_count]} messages"]
      sheet.add_row ["You used #{my_messages_details[:character_count]} characters in total"]
      sheet.add_row ["You also used #{my_messages_details[:word_count]} words in total"]
      sheet.add_row ["You also happened to use xD #{my_messages_details[:xd_count]} times"]
      sheet.add_row ['']

      sheet.add_row ['Messaging by month']
      sheet.add_row ['Month', 'number of messages']
      @counted_by[:month].sort_by { |_month, count| count }.each do |month, count|
        sheet.add_row [month, count]
      end

      sheet.add_row ['Messaging by year']
      sheet.add_row ['Year', 'number of messages']
      @counted_by[:year].sort_by { |year, _count| year }.each do |year, count|
        sheet.add_row [year, count]
      end

      sheet.add_row ['Messaging by day of week']
      sheet.add_row ['Day of week', 'number of messages']
      @counted_by[:day_of_week].sort_by { |_day, count| count }.reverse.each do |day, count|
        sheet.add_row [day, count]
      end

      sheet.add_row ['Messaging on week days vs. weekend']
      sheet.add_row ['Type of day', 'number of messages']
      @counted_by[:weekend].each do |type, count|
        sheet.add_row [type, count]
      end

      sheet.add_row ['Breakdown of messages by hour']
      sheet.add_row ['Hour', 'number of messages']
      @counted_by[:hour].sort_by { |hour, _count| hour }.each do |hour, count|
        sheet.add_row [hour, count]
      end

      sheet.add_row ['Breakdown of messages by hour and year']
      sheet.add_row ['Year and hour', 'number of messages']
      @counted_by[:year_hour].sort_by { |year_hour, _count| y, h = year_hour.split(' - '); "#{y}0".to_i + h.to_i }.each do |year_hour, count|
        sheet.add_row [year_hour, count]
      end

      sheet.add_row ['Most busy messaging days']
      sheet.add_row ['Date', 'number of messages']
      @counted_by[:date].sort_by { |_date, count| count }.reverse.each do |date, count|
        sheet.add_row [date, count]
      end
    end
  end

  def vocabulary_statistics(package:)
    my_words = word_counts_for_sender(sender: me)
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

end
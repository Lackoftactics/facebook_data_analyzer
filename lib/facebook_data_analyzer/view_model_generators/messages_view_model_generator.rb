module FacebookDataAnalyzer
  class MessagesViewModelGenerator < ViewModelGenerator
    def conversation_ranking_view_model
      sheet_name = 'Friends ranking'
      friend_ranking = FacebookDataAnalyzer::Table.new(name: 'Friend Ranking')

      friend_ranking.add_meta ['Friends ranking']
      friend_ranking.add_headers ['Rank', 'Friend/Conversation name', 'total count', 'your messages count', 'other messages count',
                                  'your characters count', 'other characters count', 'your words', 'other words']

      ranking = @messages.grouped_by[:conversation].sort_by {|_name, data| data[:message_count]}.reverse
      rank = 1
      ranking.each do |convo_name, convo_data|
        my_counts = @messages.conversation_stats_for_sender(conversation: convo_name, sender: me)

        friend_ranking.add_row [rank, convo_name, convo_data[:message_count],
                                my_counts[:message_count], convo_data[:message_count] - my_counts[:message_count],
                                my_counts[:character_count], convo_data[:character_count] - my_counts[:character_count],
                                my_counts[:word_count], convo_data[:word_count] - my_counts[:word_count]]
        rank += 1
      end

      build_view_model(model_name: sheet_name, tables: [friend_ranking])
    end

    def most_talkative_view_model
      sheet_name = 'Most Talkative'
      most_talkative = FacebookDataAnalyzer::Table.new(name: 'Most Talkative')

      most_talkative.add_headers(['Rank', "Friend's Name", 'Message Count'])

      ranking = @messages.grouped_by[:sender].sort_by {|_name, data| data[:message_count]}.reverse
      rank = 1

      ranking.each do |friend_name, convo_data|
        next if friend_name == me

        most_talkative.add_row([rank, friend_name, convo_data[:message_count]])
        rank += 1
      end

      build_view_model(model_name: sheet_name, tables: [most_talkative])
    end

    def most_words_in_common_view_model
      sheet_name = 'Words in Common per Convo'
      model_meta = [['Conversation', 'Word', 'Participants in Common', 'Count']]
      tables = []

      conversation_ranking = @messages.grouped_by[:conversation].sort_by {|_name, data| data[:message_count]}.reverse
      conversation_ranking.each do |convo_name, convo_data|
        convo_table = FacebookDataAnalyzer::Table.new(name: convo_name)
        convo_table.add_headers([convo_name])

        participants = convo_data.map {|key, value| key unless key.to_s.include?('_count')}
        participant_counts = participants.map {|sender| @messages.count_by_conversation_sender(conversation: convo_name, sender: sender)}
        participants_and_their_counts = participants.zip(participant_counts)

        words_in_common = participants_and_their_counts.each_with_object({}) do |(participant, counts), hash|
          counts[:word].each do |word, count|
            if hash.include?(word)
              hash[word][:participants] << participant
              hash[word][:count] += count
            else
              hash[word] = {participants: [participant], count: count}
            end
          end

          hash
        end

        # Limiting to max of ten words per convo
        word_count = 0
        # Sorting by number of participants then the count of the word
        words_in_common.sort_by {|_word, word_data| [word_data[:participants].count, word_data[:count]]}.reverse.each do |word, word_data|
          # Have to filter out popular words
          unless popular_word?(word: word)
            convo_table.add_row(['', word, word_data[:participants].join(', '), word_data[:count]])
            word_count += 1
          end

          break if word_count >= 10
        end

        tables << convo_table
      end

      build_view_model(model_name: sheet_name, meta: model_meta, tables: tables)
    end

    def percent_words_in_common_view_model
      sheet_name = 'Percent of Words in Common'
      percent_in_common = FacebookDataAnalyzer::Table.new(name: sheet_name)
      my_words = @messages.count_by_sender(sender: me)[:word].keys
      percent_in_common.add_meta(['Your Unique Word Count:', my_words.count])

      percent_in_common.add_headers(['Rank', 'Person', "Person's Vocab Count", '# of Words in Common', '% in Common with You', '% in Common with Them'])

      ranking = @messages.grouped_by[:sender].keys.map do |sender|
        sender_words = @messages.count_by_sender(sender: sender)[:word].keys
        num_words_in_common = (sender_words & my_words).count
        { num_words_in_common: num_words_in_common, sender: sender, sender_words: sender_words }
      end.sort_by {|data| data[:num_words_in_common]}.reverse
      rank = 1

      ranking.each do |data|
        next if data[:sender] == me

        percent_you = data[:num_words_in_common].to_f / my_words.count.to_f
        percent_them = data[:num_words_in_common].to_f / data[:sender_words].count.to_f
        percent_in_common.add_row([rank, data[:sender], data[:sender_words].count, data[:num_words_in_common], percent_you, percent_them])
        rank += 1
      end

      build_view_model(model_name: sheet_name, tables: [percent_in_common])
    end

    def number_of_corrections_view_model
      sheet_name = 'Number of Corrections'
      number_of_corrections = FacebookDataAnalyzer::Table.new(name: sheet_name)

      number_of_corrections.add_headers(['Rank', 'Person', "Person's Message Count", '# of Messages With *'])

      ranking = @messages.grouped_by[:sender].map do |sender, data|
        messages_with_star = data[:messages].map { |message| message if message.content.include? '*' }.compact
        { num_messages_with_star: messages_with_star.count, sender: sender, total_messages: data[:message_count] }
      end.sort_by {|data| data[:num_messages_with_star]}.reverse
      rank = 1

      ranking.each do |data|
        number_of_corrections.add_row([rank, data[:sender], data[:total_messages], data[:num_messages_with_star]])
        rank += 1
      end

      build_view_model(model_name: sheet_name, tables: [number_of_corrections])
    end

    def money_talk_view_model
      sheet_name = 'Money Talk'
      money_talk = FacebookDataAnalyzer::Table.new(name: sheet_name)

      money_talk.add_headers(['Rank', 'Person', "Person's Message Count", '# of Messages With $'])

      ranking = @messages.grouped_by[:sender].map do |sender, data|
        messages_with_money = data[:messages].map { |message| message if message.content.include? '$' }.compact
        { num_messages_with_money: messages_with_money.count, sender: sender, total_messages: data[:message_count] }
      end.sort_by {|data| data[:num_messages_with_money]}.reverse
      rank = 1

      ranking.each do |data|
        money_talk.add_row([rank, data[:sender], data[:total_messages], data[:num_messages_with_money]])
        rank += 1
      end

      build_view_model(model_name: sheet_name, tables: [money_talk])
    end

    def popular_conversation_words_view_model
      sheet_name = 'Popular Words per Convo'
      model_meta = [['Conversation', 'Word', 'Count']]
      tables = []

      ranked_conversations = @messages.grouped_by[:conversation].sort_by {|_name, data| data[:message_count]}.reverse.map {|convo_name, convo_data| convo_name}
      ranked_conversations.each do |conversation|
        words = @messages.grouped_by[:conversation_words][conversation]
        convo_table = FacebookDataAnalyzer::Table.new(name: conversation)
        convo_table.add_headers([conversation])

        # Limiting to max of ten words per convo
        word_count = 0
        words.sort_by {|_word, count| count}.reverse.each do |word, count|
          # Have to filter out popular words
          unless popular_word?(word: word)
            convo_table.add_row(['', word, count])
            word_count += 1
          end

          break if word_count >= 10
        end

        tables << convo_table
      end

      build_view_model(model_name: sheet_name, meta: model_meta, tables: tables)
    end

    def message_statistics_view_model
      sheet_name = 'My message statistics'
      model_meta = []
      tables = []

      my_messages_details = @messages.grouped_by[:sender][me]
      my_message_count_by = @messages.count_by_sender(sender: me)
      model_meta << ['My message statistics']
      model_meta << ["You sent in total #{my_messages_details[:message_count]} messages"]
      model_meta << ["You used #{my_messages_details[:character_count]} characters in total"]
      model_meta << ["You also used #{my_messages_details[:word_count]} words in total"]
      model_meta << ["You also happened to use xD #{my_messages_details[:xd_count]} times"]
      model_meta << ['']

      by_month = FacebookDataAnalyzer::Table.new(name: 'by_month')
      by_month.add_meta(['Messaging by month'])
      by_month.add_headers(['Month', 'total # of messages', '# of my messages'])
      @messages.counted_by[:month].sort_by {|_month, count| count}.each do |month, count|
        by_month.add_row([month, count, my_message_count_by[:month][month]])
      end
      tables << by_month

      by_year = FacebookDataAnalyzer::Table.new(name: 'by_year')
      by_year.add_meta(['Messaging by year'])
      by_year.add_headers(['Year', 'total # of messages', '# of my messages'])
      @messages.counted_by[:year].sort_by {|year, _count| year}.each do |year, count|
        by_year.add_row([year, count, my_message_count_by[:year][year]])
      end
      tables << by_year

      by_dow = FacebookDataAnalyzer::Table.new(name: 'by_dow')
      by_dow.add_meta(['Messaging by day of week'])
      by_dow.add_headers(['Day of week', 'total # of messages', '# of my messages'])
      @messages.counted_by[:day_of_week].sort_by {|_day, count| count}.reverse.each do |day, count|
        by_dow.add_row([day, count, my_message_count_by[:day_of_week][day]])
      end
      tables << by_dow

      week_weekend = FacebookDataAnalyzer::Table.new(name: 'week_weekend')
      week_weekend.add_meta(['Messaging on week days vs. weekend'])
      week_weekend.add_headers(['Type of day', 'total # of messages', '# of my messages'])
      @messages.counted_by[:weekend].each do |type, count|
        week_weekend.add_row([type, count, my_message_count_by[:weekend][type]])
      end
      tables << week_weekend

      by_hour = FacebookDataAnalyzer::Table.new(name: 'by_hour')
      by_hour.add_meta(['Breakdown of messages by hour'])
      by_hour.add_headers(['Hour', 'total # of messages', '# of my messages'])
      @messages.counted_by[:hour].sort_by {|hour, _count| hour}.each do |hour, count|
        by_hour.add_row([hour, count, my_message_count_by[:hour][hour]])
      end
      tables << by_hour

      by_hour_year = FacebookDataAnalyzer::Table.new(name: 'by_hour_year')
      by_hour_year.add_meta(['Breakdown of messages by hour and year'])
      by_hour_year.add_headers(['Year and hour', 'total # of messages', '# of my messages'])
      @messages.counted_by[:year_hour].sort_by {|year_hour, _count| y, h = year_hour.split(' - '); "#{y}0".to_i + h.to_i}.each do |year_hour, count|
        by_hour_year.add_row([year_hour, count, my_message_count_by[:year_hour][year_hour]])
      end
      tables << by_hour_year

      busy_days = FacebookDataAnalyzer::Table.new(name: 'busy_days')
      busy_days.add_meta(['Most busy messaging days'])
      busy_days.add_headers(['Date', 'total # of messages', '# of my messages'])
      @messages.counted_by[:date].sort_by {|_date, count| count}.reverse.each do |date, count|
        busy_days.add_row([date, count, my_message_count_by[:date][date]])
      end
      tables << busy_days

      build_view_model(model_name: sheet_name, meta: model_meta, tables: tables)
    end

    def vocabulary_statistics_view_model
      sheet_name = 'Vocabulary statistics'
      model_meta = []
      vocab_stats = FacebookDataAnalyzer::Table.new(name: 'Vocab Stats')
      my_words = @messages.count_by_sender(sender: me)[:word]
      my_word_count = @messages.grouped_by[:sender][me][:word_count]

      model_meta << ['Vocabulary statistics']
      model_meta << ["You used #{my_words.length} unique words and #{my_word_count} words in total"]

      @messages.most_popular_polish_words.each do |word|
        my_words.delete(word)
      end

      @messages.most_popular_english_words.each do |word|
        my_words.delete(word)
      end

      vocab_stats.add_meta(['This are cleaned results without most common english words'])
      vocab_stats.add_headers(%w[Rank Word Occurrences])

      words_ranked = my_words.sort_by {|_word, count| count}.reverse[0..999]
      rank = 1
      words_ranked.each do |word, count|
        vocab_stats.add_row([rank, word, count])
        rank += 1
      end

      build_view_model(model_name: sheet_name, meta: model_meta, tables: [vocab_stats])
    end
    
    private
    
    def me
      @messages.me
    end
    
    def popular_word?(word:)
      @messages.most_popular_english_words.include?(word) || @messages.most_popular_polish_words.include?(word)
    end
  end
end
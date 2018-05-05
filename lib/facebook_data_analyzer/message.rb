# frozen_string_literal: true

module FacebookDataAnalyzer
  class Message
    def self.parse(sender_info:, content:, conversation:)
      # To avoid searching, making a hash of child.name.child.class
      hashed_children = {}
      message_header = sender_info.children[0]
      message_header.children.each { |c| hashed_children["#{c.name}.#{c['class']}"] = c }

      sender = hashed_children['span.user'].text
      date_sent = DateTime.parse(hashed_children['span.meta'].text)
      # There are some legit messages that are empty <p>'s for some reason
      raw_content = (content&.text || 'messageremoved').downcase
      # Removes everything that's not alphanumeric (except for spaces and $)
      content = raw_content.gsub(/[^\p{AlNum}\p{Space}$]/u, '')

      Message.new(sender: sender, date_sent: date_sent, content: content, conversation: conversation)
    end

    def self.build(json_message:)
      Message.new(sender: json_message['sender'],
                  date_sent: DateTime.parse(json_message['date_sent']),
                  content: json_message['content'],
                  conversation: json_message['conversation'])
    end

    attr_reader :sender, :conversation, :date_sent, :content, :words, :word_count, :character_count, :xd_count

    def initialize(sender:, conversation:, date_sent:, content:)
      @sender = sender.to_sym
      @conversation = conversation
      @date_sent = date_sent
      @content = content
      @words = content.split(' ')
      @word_count = @words.length
      @character_count = content.length
      @xd_count = content.scan('xd').length
    end

    def content_counts
      {message_count: 1, word_count: @word_count, character_count: @character_count, xd_count: @xd_count}
    end

    def group_by_conversation
      conversation_value = {@sender => [self]}.merge(content_counts)
      {@conversation => conversation_value}
    end

    def group_by_conversation_words
      word_counts = Hash.new(0)
      @words.each { |word| word_counts[word] += 1 }
      {@conversation => word_counts}
    end

    def group_by_sender
      sender_value = {messages: [self]}.merge(content_counts)
      {@sender => sender_value}
    end

    def count_by_word
      @words
    end

    def count_by_date
      [@date_sent.strftime('%F')]
    end

    def count_by_month
      [@date_sent.strftime('%B')]
    end

    def count_by_year
      [@date_sent.year]
    end

    def count_by_day_of_week
      [@date_sent.strftime('%A')]
    end

    def count_by_hour
      [@date_sent.hour]
    end

    def count_by_weekend
      if @date_sent.friday? || @date_sent.saturday? || @date_sent.sunday?
        [:weekend]
      else
        [:working]
      end
    end

    def count_by_year_hour
      ["#{@date_sent.year} - #{@date_sent.hour}"]
    end
  end
end

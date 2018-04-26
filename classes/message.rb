class Message
  def self.parse(sender_info:, content:, conversation:)
    # To avoid searching, making a hash of child.name.child.class
    hashed_children = {}
    message_header = sender_info.children[0]
    message_header.children.each { |c| hashed_children["#{c.name}.#{c['class']}"] = c }

    sender = hashed_children['span.user'].text
    date_sent = DateTime.parse(hashed_children['span.meta'].text)
    raw_content = content.text.downcase
    # Removes everything that's not alphanumeric (except for spaces)
    content = raw_content.gsub(/[^\p{Alpha}\p{Space}-]/u, '')

    Message.new(sender: sender, date_sent: date_sent, content: content, conversation: conversation)
  end

  attr_reader :sender, :conversation, :date_sent, :content, :words, :word_count, :character_count, :xd_count

  def initialize(sender:, conversation:, date_sent:, content:)
    @sender = sender.to_sym
    @conversation = conversation.to_sym
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
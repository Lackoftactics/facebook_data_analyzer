# frozen_string_literal: true

class AnalyzeFacebookData
  attr_accessor :friends, :me, :my_messages_dates, :dictionary, :catalog

  def initialize(data_catalog)
    @friends           = {}
    @me                = Hash.new(0)
    @my_messages_dates = []
    @dictionary        = Hash.new(0)
    @catalog           = data_catalog
  end

  # AnalyzeMessages
  def start
    messages_files.each do |file|
      # open current file
      content = File.open(file)
      doc = Nokogiri::HTML(content)

      # get friend name
      friend_name = doc.title.split('Conversation with ')[1]

      # return value
      friends[friend_name] ||= {
        you_count: 0,
        you_characters: 0,
        you_words: 0,
        friend_count: 0,
        friend_characters: 0,
        friend_words: 0,
        total_count: 0
      }

      # Debug
      puts "Analyzing conversation with: #{friend_name}"

      # whole conversation
      conversation = doc.css('.thread').children

      # instance
      current_message_sender = ''

      conversation.each do |conversation_node|
        # is the converstation a message?
        if conversation_node.name == 'div' && conversation_node['class'] == 'message'
          # user sending this message
          current_message_sender  = conversation_node.css('span.user').text
          # meta conversation data
          date_info               = conversation_node.css('span.meta').text

          # who sent message, was this me or you
          if current_message_sender == user_name
            # me
            me[:total_message_count]            += 1
            friends[friend_name][:you_count]    += 1
            friends[friend_name][:total_count]  += 1
            my_messages_dates << Time.parse(date_info)
          else
            # a friend of mine
            friends[friend_name][:total_count] += 1
            friends[friend_name][:friend_count] += 1
          end
        end

        # skip this conversation node
        next unless conversation_node.name == 'p'

        # numbers about words in the conversation
        paragraph        = conversation_node.text.downcase
        paragraph        = paragraph.delete(',').delete('.')
        paragraph_length = paragraph.length
        paragraph_words  = paragraph.split(' ')

        # who sent this message, me or you?
        if current_message_sender == user_name
          # me
          me[:total_characters]   += paragraph_length
          me[:total_words]        += paragraph_words.length
          me[:total_xd]           += paragraph.scan('xd').length

          # build dictionary
          paragraph_words.each do |word|
            dictionary[word] += 1
          end

          # conversation with friend
          friends[friend_name][:you_characters] += paragraph_length
          friends[friend_name][:you_words]      += paragraph_words.length
        else
          # you
          friends[friend_name][:friend_characters]  += paragraph_length
          friends[friend_name][:friend_words]       += paragraph_words.length
        end
      end
    end
    self
  end

  def ranking
    friends.sort_by { |_name, friend| friend[:total_count] }.reverse
  end

  def messages_files
    Dir.glob("#{catalog}/messages/*.html")
  end

  def user_name
    Nokogiri::HTML(File.open("#{catalog}/index.htm")).title
            .split(' - Profile')[0]
  end
end

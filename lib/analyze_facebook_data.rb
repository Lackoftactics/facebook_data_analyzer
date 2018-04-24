# frozen_string_literal: true

class AnalyzeFacebookData

  attr_accessor :friends, :me, :my_messages_dates, :dictionary, :catalog, :user_name

  def initialize(data_catalog)
    @friends           = {}
    @me                = Hash.new(0)
    @my_messages_dates = []
    @dictionary        = Hash.new(0)
    @catalog           = data_catalog
    @user_name         = catalog_user_name
  end

  # AnalyzeMessages
  def start
    unless ENV['DEBUG']
      puts "Analyzing #{messages_files.count} messages..."
    end

    Parallel.each(messages_files, in_processes: 5) do |file|
      # open current file
      content = File.open(file)
      doc = Nokogiri::HTML(content)

      conversation_data = process_conversation(document: doc)
      save_json(file: file, data: conversation_data)
    end unless parsed_messages_files.count == messages_files.count

    semaphore = Mutex.new
    Parallel.each(parsed_messages_files, in_threads: 5) do |file|
      conversation_data = load_json(file: file)
      thread_safe_merge(other_data: conversation_data, semaphore: semaphore)
    end

    unless ENV['DEBUG']
      puts "Finished #{messages_files.count} messages..."
    end

    # Loaded from JSON files as a String - need to convert to DateTime
    @my_messages_dates.map! do |date|
      DateTime.parse(date)
    end

    self
  end

  def ranking
    friends.sort_by { |_name, friend| friend[:total_count] }.reverse
  end

  def messages_files
    Dir.glob("#{catalog}/messages/*.html")
  end

  def parsed_messages_files
    Dir.glob("#{catalog}/messages/*.json")
  end

  def catalog_user_name
    Nokogiri::HTML(File.open("#{catalog}/index.htm")).title
            .split(' - Profile')[0]
  end

  def save_json(file:, data:)
    File.open("#{file}.json", 'w') do |json_file|
      json_file.write(data.to_json)
    end
  end

  def load_json(file:)
    JSON.parse(File.read(file))
  end

  private

  def thread_safe_merge(other_data:, semaphore:)
    semaphore.synchronize do
      # Merging Dates
      @my_messages_dates += other_data['my_messages_dates']

      # Merging the me Hash
      @me[:total_message_count] += other_data['me']['total_message_count'] || 0
      @me[:total_characters] += other_data['me']['total_characters'] || 0
      @me[:total_words] +=  other_data['me']['total_words'] || 0
      @me[:total_xd] += other_data['me']['total_xd'] || 0

      # Merging Dictionary
      other_data['dictionary'].each do |word, count|
        @dictionary[word] += count
      end

      # Merging Friends
      # Assuming each conversation is a unique key (also have to convert strings to symbols)
      friends_with_symbol_keys = other_data['friends'].each_with_object({}) do |(friend, counts), new_hash|
        new_hash[friend] = {}
        counts.each do |key, value|
          new_hash[friend][key.to_sym] = value
        end

        new_hash
      end
      @friends.merge!(friends_with_symbol_keys)
    end
  end

  def process_conversation(document:)
    # get friend name
    friend_name = document.title.split('Conversation with ')[1]

    # Need to use instance variables in order to use Parallel
    message_dates = []
    my_friends = {}
    my_message_info = Hash.new(0)
    my_dictionary = Hash.new(0)

    # return value
    my_friends[friend_name] ||= {
        you_count: 0,
        you_characters: 0,
        you_words: 0,
        friend_count: 0,
        friend_characters: 0,
        friend_words: 0,
        total_count: 0
    }

    # whole conversation
    conversation = document.css('.thread').children

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
          my_message_info[:total_message_count]            += 1
          my_friends[friend_name][:you_count]    += 1
          my_friends[friend_name][:total_count]  += 1
          message_dates << date_info
        else
          # a friend of mine
          my_friends[friend_name][:total_count] += 1
          my_friends[friend_name][:friend_count] += 1
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
        my_message_info[:total_characters]   += paragraph_length
        my_message_info[:total_words]        += paragraph_words.length
        my_message_info[:total_xd]           += paragraph.scan('xd').length

        # build dictionary
        paragraph_words.each do |word|
          my_dictionary[word] += 1
        end

        # conversation with friend
        my_friends[friend_name][:you_characters] += paragraph_length
        my_friends[friend_name][:you_words]      += paragraph_words.length
      else
        # you
        my_friends[friend_name][:friend_characters]  += paragraph_length
        my_friends[friend_name][:friend_words]       += paragraph_words.length
      end
    end

    {me: my_message_info, my_messages_dates: message_dates, friends: my_friends, dictionary: my_dictionary}
  end
end

# frozen_string_literal: true

# My script for 'I analyzed my facebook data and it's story of shyness, loneliness and change'

require 'nokogiri'
require 'axlsx'

require_relative 'lib/analyze_facebook_data.rb'
require_relative 'lib/making_friends_data.rb'
require_relative 'lib/messages_sent.rb'
require_relative 'lib/friends_dates.rb'
require_relative 'lib/contact_list.rb'

# images exchanged
# links exchanged
# percent conversation
# characters written
# words written
# most xD conversation
# most emoji expressive conversation
# messages sent by month
# messages sent by year
# type of texter: night owl, before noon, afternoon
# most used words
# how many times you used xD
# messages during working hours

# my most popular words are almost https://en.wiktionary.org/wiki/Wiktionary:Frequency_lists/Polish_wordlist

# how much friends you gained by year
# how much friends gained during weekday
# friends gained by month
# rank everything

analyze_facebook_data = AnalyzeFacebookData.new(ARGV[0]).start

# CreatePackage
package = Axlsx::Package.new
package.workbook.add_worksheet(name: 'Friends ranking') do |sheet|
  sheet.add_row ['Friends ranking']
  sheet.add_row ['Rank', 'Friend name', 'total count', 'your messages count', 'friend messages count', 'your characters count', 'friend characters count', 'your words', 'friend words']
  rank = 1
  analyze_facebook_data.ranking.each do |friend_name, friend_data|
    sheet.add_row [rank, friend_name,
                   friend_data[:total_count], friend_data[:you_count],
                   friend_data[:friend_count], friend_data[:you_characters],
                   friend_data[:friend_characters], friend_data[:you_words],
                   friend_data[:friend_words]]
    rank += 1
  end
end

messages_sent = MessagesSent.new(analyze_facebook_data.my_messages_dates).build

package.workbook.add_worksheet(name: 'My message statistics') do |sheet|
  sheet.add_row ['My message statistics']
  sheet.add_row ["You sent in total #{analyze_facebook_data.me[:total_message_count]} messages"]
  sheet.add_row ["You used #{analyze_facebook_data.me[:total_characters]} characters in total"]
  sheet.add_row ["You also used #{analyze_facebook_data.me[:total_words]} words in total"]
  sheet.add_row ["You also happened to use xD #{analyze_facebook_data.me[:total_xd]} times"]
  sheet.add_row ['']

  sheet.add_row ['Messaging by month']
  sheet.add_row ['Month', 'number of messages']

  messages_sent.by_month.sort_by { |_month, count| count }.each do |month, count|
    sheet.add_row [month, count]
  end

  sheet.add_row ['Messaging by year']
  sheet.add_row ['Year', 'number of messages']

  messages_sent.by_year.sort_by { |year, _count| year }.each do |year, count|
    sheet.add_row [year, count]
  end

  sheet.add_row ['Messaging by day of week']
  sheet.add_row ['Day of week', 'number of messages']

  messages_sent.by_day_of_week.sort_by { |_day, count| count }.reverse.each do |day, count|
    sheet.add_row [day, count]
  end

  sheet.add_row ['Messaging on week days vs. weekend']
  sheet.add_row ['Type of day', 'number of messages']

  messages_sent.by_weekend.each do |type, count|
    sheet.add_row [type, count]
  end

  sheet.add_row ['Breakdown of messages by hour']
  sheet.add_row ['Hour', 'number of messages']

  messages_sent.by_hour.sort_by { |hour, _count| hour }.each do |hour, count|
    sheet.add_row [hour, count]
  end

  sheet.add_row ['Breakdown of messages by hour and year']
  sheet.add_row ['Year and hour', 'number of messages']

  messages_sent.by_year_hour.sort_by { |year_hour, _count| y, h = year_hour.split(' - '); "#{y}0".to_i + h.to_i }.each do |year_hour, count|
    sheet.add_row [year_hour, count]
  end

  sheet.add_row ['Most busy messaging days']
  sheet.add_row ['Date', 'number of messages']

  messages_sent.by_date.sort_by { |_date, count| count }.reverse.each do |date, count|
    sheet.add_row [date, count]
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


package.workbook.add_worksheet(name: 'Vocabulary statistics') do |sheet|
  sheet.add_row ['Vocabulary statistics']
  sheet.add_row ["You used #{analyze_facebook_data.dictionary.length} unique words and #{analyze_facebook_data.me[:total_words]} words in total"]

  most_popular_polish_words.each do |word|
    analyze_facebook_data.dictionary.delete(word)
  end

  most_popular_english_words.each do |word|
    analyze_facebook_data.dictionary.delete(word)
  end

  sheet.add_row ['This are cleaned results without most common english words']
  sheet.add_row %w[Rank Word Occurences]

  words_ranked = analyze_facebook_data.dictionary.sort_by { |_word, count| count }.reverse[0..999]
  rank = 1
  words_ranked.each do |word, count|
    sheet.add_row [rank, word, count]
    rank += 1
  end
end

contact_list = ContactList.new(analyze_facebook_data.catalog).run

package.workbook.add_worksheet(name: 'Contact list') do |sheet|
  sheet.add_row ['Contact list']
  sheet.add_row ["Facebook imported #{contact_list.contacts.length} of your contacts"]
  sheet.add_row ['Name', 'Phone number']

  contact_list.contacts.sort_by { |contact_name, _info| contact_name }
                       .each do |contact_name, contact_num|
                         sheet.add_row [contact_name, contact_num]
                       end
end

analyze_friends_dates = FriendsDates.analyze(analyze_facebook_data.catalog).friends_dates
making_friends = MakingFriendsData.new(analyze_friends_dates).build

package.workbook.add_worksheet(name: 'Making friends') do |sheet|
  sheet.add_row ['Making friends']
  sheet.add_row ['']
  sheet.add_row ['Making friends by year']
  sheet.add_row ['Year', 'Number of friends added']

  making_friends.by_year.sort_by { |year, _count| year }.each do |year, count|
    sheet.add_row [year, count]
  end

  sheet.add_row ['Making friends by week day']
  sheet.add_row ['Day of week', 'Number of friends added']

  making_friends.by_week_day.sort_by { |_day, count| count }.reverse.each do |day, count|
    sheet.add_row [day, count]
  end

  sheet.add_row ['Making friends by month']
  sheet.add_row ['Month', 'Number of friends added']

  making_friends.by_month.sort_by { |_month, count| count }.reverse.each do |month, count|
    sheet.add_row [month, count]
  end

  sheet.add_row ['Making friends on weekend vs. working days']
  sheet.add_row ['Working day or weekend', 'Number of friends added']

  making_friends.by_weekend.each do |type_of_day, count|
    sheet.add_row [type_of_day.to_s, count]
  end

  sheet.add_row ['Most busy weeks for making friends (week number and year)']
  sheet.add_row ['Week and year', 'Number of friends added']

  making_friends.by_week_and_year.sort_by { |_week_year, count| count }.reverse.each do |week_year, count|
    sheet.add_row [week_year, count]
  end

  sheet.add_row ['Most busy month-year by friends added']
  sheet.add_row ['Month year', 'Number of friends added']

  making_friends.by_month_and_year.sort_by { |_month_year, count| count }.reverse.each do |month_year, count|
    sheet.add_row [month_year, count]
  end

  sheet.add_row ['Most busy making friends days']
  sheet.add_row ['Day', 'Number of friends added']

  making_friends.by_day.sort_by { |_day, count| count }.reverse.each do |day, count|
    sheet.add_row [day, count]
  end
end

package.serialize('facebook_analysis.xlsx')

# frozen_string_literal: true

# My script for 'I analyzed my facebook data and it's story of shyness, loneliness and change'

require 'nokogiri'
require 'axlsx'

require_relative 'lib/analyze_facebook_data.rb'
require_relative 'lib/making_friends_data.rb'
require_relative 'lib/messages_sent.rb'
require_relative 'lib/friends_dates.rb'
require_relative 'lib/contact_list.rb'
require_relative 'lib/friends_ranking_sheet.rb'
require_relative 'lib/message_statistics_sheet.rb'
require_relative 'lib/making_friends_sheet.rb'
require_relative 'lib/contact_list_sheet.rb'

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
  FriendsRankingSheet.build(ranking: analyze_facebook_data.ranking, sheet: sheet)
end

messages_sent = MessagesSent.new(analyze_facebook_data.my_messages_dates).build

package.workbook.add_worksheet(name: 'My message statistics') do |sheet|
  MessageStatisticsSheet.build(me: analyze_facebook_data.me, messages_sent: messages_sent, sheet: sheet)
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
  ContactListSheet.build(contacts: contact_list.contacts, sheet: sheet)
end

analyze_friends_dates = FriendsDates.analyze(analyze_facebook_data.catalog).friends_dates
making_friends = MakingFriendsData.new(analyze_friends_dates).build

package.workbook.add_worksheet(name: 'Making friends') do |sheet|
  MakingFriendsSheet.build(making_friends: making_friends, sheet: sheet)
end

package.serialize('facebook_analysis.xlsx')

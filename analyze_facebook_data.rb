# frozen_string_literal: true

# My script for 'I analyzed my facebook data and it's story of shyness, loneliness and change'

require 'nokogiri'
require 'axlsx'

# parsing the data
require_relative 'lib/analyze_facebook_data.rb'
require_relative 'lib/making_friends_data.rb'

# sort the data for using in workbook sheets
require_relative 'lib/messages_sent.rb'
require_relative 'lib/friends_dates.rb'
require_relative 'lib/contact_list.rb'

# creating workbook sheets
require_relative 'lib/friends_ranking_sheet.rb'
require_relative 'lib/message_statistics_sheet.rb'
require_relative 'lib/making_friends_sheet.rb'
require_relative 'lib/contact_list_sheet.rb'
require_relative 'lib/vocabulary_statistics_sheet.rb'

# sort of helper
require_relative 'lib/most_popular_words.rb'

# creates a xlsx file
require_relative 'lib/workbook.rb'

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

Workbook.new(catalog: ARGV[0])











# frozen_string_literal: true

# My script for 'I analyzed my facebook data and it's story of shyness, loneliness and change'

require 'bundler/setup'
Bundler.require

require_relative 'classes/analyzeables/analyzeable'
require_relative 'classes/analyzeables/contacts'
require_relative 'classes/analyzeables/friends'
require_relative 'classes/analyzeables/messages'
require_relative 'classes/contact'
require_relative 'classes/friend'
require_relative 'classes/message'


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


catalog = ARGV[0]
package = Axlsx::Package.new
analyzeables = [Messages.new(catalog: catalog, parallel: true), Contacts.new(catalog: catalog), Friends.new(catalog: catalog)]

analyzeables.each do |analyzeable|
  analyzeable.analyze
  analyzeable.export(package: package)
end

package.serialize('facebook_analysis.xlsx')

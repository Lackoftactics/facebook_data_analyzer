require 'pry'
require 'parallel'
require 'json'
require 'date'

require_relative '../classes/analyzeables/analyzeable'
require_relative '../classes/analyzeables/contacts'
require_relative '../classes/analyzeables/friends'
require_relative '../classes/analyzeables/messages'
require_relative '../classes/contact'
require_relative '../classes/friend'
require_relative '../classes/message'

# Support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  config.include TestCatalog # include my TestCatalog module from inside the support directory
end
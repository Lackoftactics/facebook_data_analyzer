# frozen_string_literal: true

require 'bundler/setup'
require 'pry'
require 'dotenv/load' # this loads an .env file from the root of the project
require 'facebook_data_analyzer'

# Support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.include TestCatalog # include my TestCatalog module from inside the support directory
end
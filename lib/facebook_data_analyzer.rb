# frozen_string_literal: true

# My script for 'I analyzed my facebook data and it's story of shyness,
# loneliness and change'
require 'axlsx'
require 'parallel'
require 'json'
require 'workbook'
require 'set'

require 'facebook_data_analyzer/analyzeables/analyzeable'
require 'facebook_data_analyzer/analyzeables/contacts'
require 'facebook_data_analyzer/analyzeables/friends'
require 'facebook_data_analyzer/analyzeables/messages'
require 'facebook_data_analyzer/contact'
require 'facebook_data_analyzer/friend'
require 'facebook_data_analyzer/message'

module FacebookDataAnalyzer
  def self.run(options = {})
    file_output    = 'facebook_data_analyzer'
    catalog        = options.fetch(:catalog)
    xlsx           = [options.fetch(:filename, file_output), 'xlsx'].join('.')
    html           = [options.fetch(:filename, file_output), 'html'].join('.')
    parallel_usage = options.fetch(:parallel, false)

    package = Axlsx::Package.new

    analyzeables = [Messages.new(catalog: catalog, options: options),
                    Contacts.new(catalog: catalog),
                    Friends.new(catalog: catalog)]

    analyzeables.each do |analyzeable|
      analyzeable.analyze
      analyzeable.export(package: package)
    end

    puts "= Export #{xlsx}"
    package.serialize(xlsx)

    puts "= Export #{html}"
    b = Workbook::Book.open(xlsx)
    b.write_to_html(html)
  end
end

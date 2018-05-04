# frozen_string_literal: true

# My script for 'I analyzed my facebook data and it's story of shyness,
# loneliness and change'
module FacebookDataAnalyzer
  require 'facebook_data_analyzer/analyzeables/analyzeable'
  require 'facebook_data_analyzer/analyzeables/contacts'
  require 'facebook_data_analyzer/analyzeables/friends'
  require 'facebook_data_analyzer/analyzeables/messages'
  require 'facebook_data_analyzer/contact'
  require 'facebook_data_analyzer/friend'
  require 'facebook_data_analyzer/message'

  require 'axlsx'
  require 'parallel'
  require 'json'
  require 'workbook'

  def self.run
    catalog = ARGV[0]
    package = ::Axlsx::Package.new

    analyzeables = [Messages.new(catalog: catalog, parallel: true),
                    Contacts.new(catalog: catalog),
                    Friends.new(catalog: catalog)]

    analyzeables.each do |analyzeable|
      analyzeable.analyze
      analyzeable.export(package: package)
    end

    package.serialize('facebook_analysis.xlsx')
    b = ::Workbook::Book.open('facebook_analysis.xlsx')
    b.write_to_html('facebook_analysis.html')
  end
end

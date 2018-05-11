# frozen_string_literal: true

# My script for 'I analyzed my facebook data and it's story of shyness,
# loneliness and change'
module FacebookDataAnalyzer
  require 'facebook_data_analyzer/view_model_generators/view_model_generator'
  require 'facebook_data_analyzer/view_model_generators/friends_view_model_generator'
  require 'facebook_data_analyzer/view_model_generators/contacts_view_model_generator'
  require 'facebook_data_analyzer/view_model_generators/messages_view_model_generator'
  require 'facebook_data_analyzer/mixins/excel_exporter_mixin'
  require 'facebook_data_analyzer/mixins/export_views_mixin'
  require 'facebook_data_analyzer/analyzeable'
  require 'facebook_data_analyzer/contacts'
  require 'facebook_data_analyzer/friends'
  require 'facebook_data_analyzer/messages'
  require 'facebook_data_analyzer/models/contact'
  require 'facebook_data_analyzer/models/friend'
  require 'facebook_data_analyzer/models/message'
  require 'facebook_data_analyzer/models/table'

  require 'axlsx'
  require 'parallel'
  require 'json'
  require 'workbook'
  require 'set'

  def self.run(options = {})
    catalog        = options.fetch(:catalog)
    xlsx           = [options.fetch(:filename), 'xlsx'].join('.')
    html           = [options.fetch(:filename), 'html'].join('.')
    parallel_usage = options.fetch(:parallel)

    package = ::Axlsx::Package.new

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
    b = ::Workbook::Book.open(xlsx)
    b.write_to_html(html)
  end
end

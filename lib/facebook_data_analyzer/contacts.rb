# frozen_string_literal: true

module FacebookDataAnalyzer
  class Contacts < Analyzeable
    include FacebookDataAnalyzer::ExportViewsMixin
    attr_reader :contacts

    EXPORTS = [:contact_list].freeze

    def initialize(catalog:)
      @catalog = catalog
      @directory = "#{catalog}/html/"
      @file_pattern = 'contact_info.htm'
      @contacts = []

      super()
    end

    def analyze
      Dir.chdir(@directory) do
        content = File.open(@file_pattern).read
        doc = Nokogiri::HTML(content)

        contacts_rows = doc.css('div.contents tr')

        unique_contacts = contacts_rows.each_with_object({}) do |contact, seen_contacts|
          text = contact.text

          next if text == 'NameContacts'

          seen_contacts[text] = Contact.parse(contact_text: text)
        end

        unique_contacts.values.each do |contact|
          @contacts << contact
        end
      end
    end
  end
end

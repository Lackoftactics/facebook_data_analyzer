# frozen_string_literal: true

module FacebookDataAnalyzer
  class Contacts < Analyzeable
    attr_reader :contacts
    def initialize(catalog:)
      @catalog = catalog
      @directory = "#{catalog}/about_you/"
      @file_pattern = 'your_address_books.html'
      @contacts = []

      super()
    end

    def analyze
      Dir.chdir(@directory) do
        content = File.open(@file_pattern).read
        doc = Nokogiri::HTML(content)

        contacts_rows = doc.at_css('._4t5n').children

        unique_contacts = contacts_rows.each_with_object({}) do |contact, seen_contacts|
          seen_contacts[contact.children[0].text] = Contact.parse(contact_text: contact)
        end

        unique_contacts.values.each do |contact|
          @contacts << contact
        end
      end
    end

    def export(package:)
      contact_list_sheet(package: package)
    end

    private

    def contact_list_sheet(package:)
      package.workbook.add_worksheet(name: 'Contact list') do |sheet|
        sheet.add_row ['Contact list']
        sheet.add_row ["Facebook imported #{@contacts.length} of your contacts"]
        sheet.add_row ['Name', 'Email']
        @contacts.sort_by(&:name).each do |contact|
          sheet.add_row [contact.name, contact.details]
        end
      end
    end
  end
end

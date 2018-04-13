class Contacts < Analyzeable

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

      unique_contacts = contacts_rows.map do |contact|
        text = contact.text

        next if text == 'NameContacts'

        Contact.parse(contact_text: text)
      end.compact.uniq

      unique_contacts.each do |contact|
        contact = Contact.new(name: contact[:name], details: contact[:details])

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
      sheet.add_row ['Name', 'Phone number']
      @contacts.sort_by { |contact| contact.name }.each do |contact|
        sheet.add_row [contact.name, contact.details]
      end
    end
  end
end
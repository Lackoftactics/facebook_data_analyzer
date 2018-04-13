class Contacts
  GROUP_BY = [].freeze
  COUNT_BY = [].freeze

  def initialize(catalog:)
    @catalog = catalog
    @directory = "#{catalog}/html/"
    @file_pattern = 'contact_info.htm'
    @contacts = []
    @grouped_by = Hash.new( Hash.new( Hash.new([]) ) )
    @counted_by = Hash.new( Hash.new(0) )
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

  def group!(message:)
    GROUP_BY.each do |attribute|
      grouping_method = "group_by_#{attribute}".to_sym

      if message.respond_to?(grouping_method)
        grouped_message = message.send(grouping_method)

        grouped_message.each do |group, group_attributes|
          group_attributes.each do |group_attribute_key, group_attribute_value|
            @grouped_by[attribute][group][group_attribute_key] += group_attribute_value
          end
        end
      end
    end
  end

  def count!(message:)
    COUNT_BY.each do |attribute|
      counting_method = "count_by_#{attribute}".to_sym

      if message.respond_to?(counting_method)
        countables = message.send(counting_method)

        countables.each do |countable|
          @counted_by[attribute][countable.to_sym] += 1
        end
      end
    end
  end

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
class Contacts
  GROUP_BY = [].freeze
  COUNT_BY = [].freeze

  def initialize(catalog:)
    @catalog = catalog
    @directory = "#{catalog}/html/"
    @file_pattern = 'contact_info.htm'
    @contacts = []

    # Grouped by is weird and needs a hash for each GROUP_BY, hash for each unique group, and hash for attributes
    @grouped_by = Hash.new do |by_group, key|
      by_group[key] = Hash.new do |group_name, attribute|
        group_name[attribute] = Hash.new(nil)
      end
    end
    @counted_by = Hash.new { |hash, key| hash[key] = Hash.new(0) }
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

  def group!(analyzeable:)
    GROUP_BY.each do |attribute|
      grouping_method = "group_by_#{attribute}".to_sym

      if analyzeable.respond_to?(grouping_method)
        grouped_analyzeable = analyzeable.send(grouping_method)

        grouped_analyzeable.each do |group, group_attributes|
          group_attributes.each do |group_attribute_key, group_attribute_value|
            current_grouping = @grouped_by[attribute][group][group_attribute_key]
            if current_grouping.nil?
              @grouped_by[attribute][group][group_attribute_key] = group_attribute_value
            else
              @grouped_by[attribute][group][group_attribute_key] += group_attribute_value
            end
          end
        end
      end
    end
  end

  def count!(analyzeable:)
    COUNT_BY.each do |attribute|
      counting_method = "count_by_#{attribute}".to_sym

      if analyzeable.respond_to?(counting_method)
        countables = analyzeable.send(counting_method)

        countables.each do |countable|
          @counted_by[attribute][countable] += 1
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
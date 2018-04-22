# frozen_string_literal: true

class ContactList
  # contact info data
  # how much facebook archived
  attr_reader :contacts, :catalog

  def initialize(data_catalog)
    @catalog = data_catalog
  end

  def build
    @contacts = contacts_rows.map do |contact|
      text = contact.text
      if text == 'NameContacts'
      else
        contact_info = text.split('contact: ')
        [String(contact_info[0]), contact_info[1..3].join(' ')]
      end
    end.compact.uniq
    self
  end

  def doc
    Nokogiri::HTML(content)
  end

  def content
    File.open("#{catalog}/html/contact_info.htm").read
  end

  def contacts_rows
    doc.css('div.contents tr')
  end
end

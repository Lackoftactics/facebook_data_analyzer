class Contact
  def self.parse(contact_text:)
    contact_info = contact_text.split('contact: ')

    {name: String(contact_info[0]), details: contact_info[1..3].join(' ')}
  end

  attr_reader :name, :details

  def initialize(name:, details:)
    @name = name
    @details = details
  end
end
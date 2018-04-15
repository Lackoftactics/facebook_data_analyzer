# frozen_string_literal: true

class ContactListSheet
  def self.build(contacts:, sheet:)
    sheet.add_row ['Contact list']
    sheet.add_row ["Facebook imported #{contacts.length} of your contacts"]
    sheet.add_row ['Name', 'Phone number']

    contacts.sort_by { |contact_name, _info| contact_name }.each do |contact_name, contact_num|
      sheet.add_row [contact_name, contact_num]
    end
  end
end

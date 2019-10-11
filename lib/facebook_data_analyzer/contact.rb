# frozen_string_literal: true

module FacebookDataAnalyzer
  class Contact
    def self.parse(contact_text:)
      name_text = contact_text.children[0].text
      details = contact_text.children.drop(1)

      Contact.new(name: String(name_text), details: details.join(' '))
    end

    attr_reader :name, :details

    def initialize(name:, details:)
      @name = name
      @details = details
    end
  end
end

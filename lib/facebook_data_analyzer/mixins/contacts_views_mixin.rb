module FacebookDataAnalyzer
  module ContactsViewsMixin
    def export(package:)
      contact_list_sheet(package: package)
    end

    private

    def contact_list_sheet(package:)
      package.workbook.add_worksheet(name: 'Contact list') do |sheet|
        sheet.add_row ['Contact list']
        sheet.add_row ["Facebook imported #{@contacts.length} of your contacts"]
        sheet.add_row ['Name', 'Phone number']
        @contacts.sort_by(&:name).each do |contact|
          sheet.add_row [contact.name, contact.details]
        end
      end
    end
  end
end

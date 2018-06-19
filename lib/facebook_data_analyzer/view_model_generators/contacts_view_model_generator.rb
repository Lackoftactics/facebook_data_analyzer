module FacebookDataAnalyzer
  class ContactsViewModelGenerator < ViewModelGenerator
    def contact_list_view_model
      sheet_name = 'Contact List'
      model_meta = []
      contact_list = FacebookDataAnalyzer::Table.new(name: 'Contact List')

      model_meta << ['Contact list']
      model_meta << ["Facebook imported #{@contacts.contacts.length} of your contacts"]
      contact_list.add_headers(['Name', 'Phone number'])
      @contacts.contacts.sort_by(&:name).each do |contact|
        contact_list.add_row([contact.name, contact.details])
      end

      build_view_model(model_name: sheet_name, meta: model_meta, tables: [contact_list])
    end
  end
end
RSpec.describe FacebookDataAnalyzer::Contacts do
  subject do
    described_class.new(catalog: test_catalog)
  end

  before(:each) do
    subject.analyze
  end

  describe '#analyze' do
    it 'should return proper @contacts details for first contact' do
      contact = subject.contacts.first
      expect(contact.name).to eq("Lou Gregory")
      expect(contact.details).to eq("lgregory@gmail.com")
      expect(contact.name).to_not eq("Cindy Walker")
      expect(subject.contacts.count).to eq(10)
    end
  end
end

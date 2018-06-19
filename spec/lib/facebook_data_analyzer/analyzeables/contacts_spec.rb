RSpec.describe FacebookDataAnalyzer::Contacts do
  subject do
    described_class.new(catalog: test_catalog)
  end

  before(:each) do
    subject.analyze
  end

  describe '#analyze' do
    let(:contact) { subject.contacts.first }

    it 'should return proper @contacts details for first contact' do
      expect(contact.name).to eq('Lou Gregory')
      expect(contact.details).to eq('lgregory@gmail.com')
      expect(contact.name).to_not eq('Cindy Walker')
      expect(subject.contacts.count).to eq(10)
    end
  end
end

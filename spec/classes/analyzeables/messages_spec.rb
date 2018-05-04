RSpec.describe Messages do
  subject { described_class.new(catalog: test_catalog, parallel: false) }

  describe '#analyze' do # # - that's an instance method
    it 'should return proper @messages' do
      subject.analyze
      message = subject.messages.first
      expect(message.word_count).to eq(6)
      expect(subject.messages.count).to eq(78)
      # other similar tests here...
    end
  end

  describe '#count' do
    # ...
  end

  describe '#group' do

  end
end
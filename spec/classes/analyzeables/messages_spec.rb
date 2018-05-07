RSpec.describe FacebookDataAnalyzer::Messages do
  subject {
    described_class.new(catalog: test_catalog, options: {parallel: false} )
  }

  describe '#analyze' do # # - that's an instance method
    it 'should return proper @messages' do
      subject.analyze
      message = subject.messages.first

      expect(message.character_count).to eq(304)
      expect(message.word_count).to eq(53)
      expect(message.sender).to eq(:"Allison Walker")
      expect(message.words).to eq(["hello", "friends", "family", "and", "dance", "students", "please", "help", "me", "promote", "my", "wedding", "dance", "choreography", "page", "in", "this", "difficult", "economy", "i", "need", "to", "have", "as", "many", "likes", "as", "possible", "to", "get", "higher", "in", "the", "search", "engines", "so", "please", "go", "onto", "my", "page", "wedding", "dance", "choreography", "and", "like", "us", "i", "really", "appreciate", "it", "thanks", "allison"])
      expect(message.content).to eq("hello friends family and dance students please help me promote my wedding dance choreography page in this difficult economy i need to have as many likes as possible to get higher in the search engines so please go onto my page wedding dance choreography and like us i really appreciate it  thanks allison")
      expect(message.conversation).to eq("Allison Walker")
      expect(message.date_sent.to_s).to eq("2012-01-29T14:55:00-05:00")
    end
  end

  describe '#count' do
    it "should count grouped messages correctly" do
      subject.analyze
      counted = subject.counted_by
      binding.pry
    end
  end

  describe '#group' do

  end
end
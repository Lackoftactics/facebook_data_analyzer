RSpec.describe FacebookDataAnalyzer::Messages do
  subject do
    described_class.new(catalog: test_catalog, options: {parallel: false} )
  end

  before(:each) do
    subject.analyze
  end

  describe '#analyze' do
    it 'should return proper @messages' do
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
      counted = subject.counted_by
      expect(counted[:date]["2012-01-29"]).to eq(1)
      expect(counted[:year][2012]).to eq(1)
    end
  end

  describe '#group' do
    it "should group messages correctly" do
      grouped = subject.grouped_by
      message = grouped[:conversation]["Allison Walker"][:"Allison Walker"].first
      expect(message.sender).to eq(:"Allison Walker")
      expect(message.words).to include('hello')
    end
  end
end
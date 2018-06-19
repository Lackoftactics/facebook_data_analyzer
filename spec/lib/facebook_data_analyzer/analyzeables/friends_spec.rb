RSpec.describe FacebookDataAnalyzer::Friends do
  subject do
    described_class.new(catalog: test_catalog)
  end

  before(:each) do
    subject.analyze
  end

  describe '#analyze' do
    let(:friend) { subject.friends.first }

    it 'should return proper friends details' do
      expect(friend.name).to eq('Isaac Perez')
      expect(friend.date_added.to_s).to eq("2017-11-05T00:00:00+00:00")
    end
  end

  describe '#total' do
    let(:all_friends) { subject.friends }

    it 'should return correct friends count' do
      expect(all_friends.count).to eq(105)
    end
  end


  describe '#count' do
    let(:counted) { subject.counted_by }

    it "should count adding friends correctly" do
      expect(counted[:year][2017]).to eq(7)
      expect(counted[:day_of_week]['Sunday']).to eq(23)
      expect(counted[:month]['August']).to eq(15)
      expect(counted[:weekend][:working]).to eq(51)
      expect(counted[:week_year]['week 14 of 2015']).to eq(2)
      expect(counted[:month_year]['October - 2016']).to eq(10)
      expect(counted[:day]['2016-09-15']).to eq(3)
    end
  end
end

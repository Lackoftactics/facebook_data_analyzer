RSpec.describe FacebookDataAnalyzer do
  before(:all) { described_class.run(catalog: test_catalog) }

  describe  '.run' do
    context '.xlsx' do
      let!(:workbook) { Workbook::Book.open 'facebook_data_analyzer.xlsx' }

      it 'generates "Friends ranking" worksheet correctly' do
        sheet = workbook[0]
        table = sheet.table
        expect(table['B3'].value).to eq('Suzanne Nash')
        expect(table['C4'].value).to eq(22)
        expect(table['D5'].value).to eq(12)
        expect(table['E6'].value).to eq(4)
        expect(table['G7'].value).to eq(304)
      end

      it 'generates "Most Talkative" worksheet correctly' do
        sheet = workbook[1]
        table = sheet.table
        expect(table['B2'].value).to eq('Kate Hunter')
        expect(table['C3'].value).to eq(12)
        expect(table['B5'].value).to eq('Cindi Gray')
        expect(table['C6'].value).to eq(1)
      end

      it 'generates "My message statistics" worksheet correctly' do
        sheet = workbook[2]
        table = sheet.table
        expect(table['A2'].value).to eq('You sent in total 39 messages')
        expect(table['C12'].value).to eq(17)
        expect(table['B17'].value).to eq(31)
        expect(table['C29'].value + table['C30'].value).to eq(39)
        expect(table['B83'].value).to eq(9)
      end

      it 'generates "Vocabulary statistics" worksheet correctly' do
        sheet = workbook[3]
        table = sheet.table
        expect(table['A2'].value).to eq('You used 212 unique words and 508 words in total')
        expect(table['B6'].value).to eq('morning')
        expect(table['C8'].value).to eq(5)
      end

      it 'generates "Popular Words per Conversation" worksheet correctly' do
        sheet = workbook[4]
        table = sheet.table
        expect(table['A26'].value).to eq('Abbie Carter')
        expect(table['B39'].value).to eq('front')
        expect(table['C51'].value).to eq(3)
      end
    end

    context '.html' do
      let!(:workbook) { Nokogiri::HTML open('facebook_data_analyzer.html') }

      it 'generates "Friends ranking" html output correctly' do
        workbook.xpath('//table[1]').first.content
        expect(workbook.xpath('//table[1]//tr[2]/td[2]').first.content).to eq('Suzanne Nash')
        expect(workbook.xpath('//table[1]//tr[3]/td[3]').first.content).to eq('22')
        expect(workbook.xpath('//table[1]//tr[4]/td[4]').first.content).to eq('12')
        expect(workbook.xpath('//table[1]//tr[5]/td[5]').first.content).to eq('4')
        expect(workbook.xpath('//table[1]//tr[6]/td[7]').first.content).to eq('304')
      end

      it 'generates "Most Talkative" html output correctly' do
        workbook.xpath('//table[2]').first.content
        expect(workbook.xpath('//table[2]//tr[1]/td[2]').first.content).to eq('Kate Hunter')
        expect(workbook.xpath('//table[2]//tr[2]/td[3]').first.content).to eq('12')
        expect(workbook.xpath('//table[2]//tr[4]/td[2]').first.content).to eq('Cindi Gray')
        expect(workbook.xpath('//table[2]//tr[5]/td[3]').first.content).to eq('1')
      end

      it 'generates "My message statistics" html output correctly' do
        workbook.xpath('//table[3]').first.content
        expect(workbook.xpath('//table[3]//tr[1]/td[1]').first.content).to eq('You sent in total 39 messages')
        expect(workbook.xpath('//table[3]//tr[11]/td[3]').first.content).to eq('17')
        expect(workbook.xpath('//table[3]//tr[16]/td[2]').first.content).to eq('31')
        expect((workbook.xpath('//table[3]//tr[28]/td[3]').first.content.to_i)+(workbook.xpath('//table[3]//tr[29]/td[3]').first.content.to_i)).to eq(39)
        expect(workbook.xpath('//table[3]//tr[82]/td[2]').first.content).to eq('9')
      end

      it 'generates "Vocabulary statistics" html output correctly' do
        workbook.xpath('//table[4]').first.content
        expect(workbook.xpath('//table[4]//tr[1]/td[1]').first.content).to eq('You used 212 unique words and 508 words in total')
        expect(workbook.xpath('//table[4]//tr[5]/td[2]').first.content).to eq('morning')
        expect(workbook.xpath('//table[4]//tr[7]/td[3]').first.content).to eq('5')
      end

      it 'generates "Popular Words per Conversation" html output correctly' do
        workbook.xpath('//table[5]').first.content
        expect(workbook.xpath('//table[5]//tr[25]/td[1]').first.content).to eq('Abbie Carter')
        expect(workbook.xpath('//table[5]//tr[38]/td[2]').first.content).to eq('front')
        expect(workbook.xpath('//table[5]//tr[50]/td[3]').first.content).to eq('3')
      end
    end
  end
end

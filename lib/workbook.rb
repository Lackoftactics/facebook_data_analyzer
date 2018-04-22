# frozen_string_literal: true

class Workbook
  def initialize(catalog: input_catalog)
    analyze_facebook_data = AnalyzeFacebookData.new(catalog).start
    messages_sent         = MessagesSent.new(analyze_facebook_data.my_messages_dates).build
    contact_list          = ContactList.new(analyze_facebook_data.catalog).build
    analyze_friends_dates = FriendsDates.analyze(analyze_facebook_data.catalog).friends_dates
    making_friends        = MakingFriendsData.new(analyze_friends_dates).build

    # CreatePackage
    package = Axlsx::Package.new

    package.workbook.add_worksheet(name: 'Friends ranking') do |sheet|
      FriendsRankingSheet.build(ranking: analyze_facebook_data.ranking, sheet: sheet)
    end

    package.workbook.add_worksheet(name: 'My message statistics') do |sheet|
      MessageStatisticsSheet.build(me: analyze_facebook_data.me, messages_sent: messages_sent, sheet: sheet)
    end

    package.workbook.add_worksheet(name: 'Vocabulary statistics') do |sheet|
      VocabularyStatisticsSheet.build(dictionary: analyze_facebook_data.dictionary,
                                      me: analyze_facebook_data.me,
                                      most_popular_english_words: MostPopularWords.most_popular_english_words,
                                      most_popular_polish_words: MostPopularWords.most_popular_polish_words,
                                      sheet: sheet)
    end

    package.workbook.add_worksheet(name: 'Contact list') do |sheet|
      ContactListSheet.build(contacts: contact_list.contacts, sheet: sheet)
    end

    package.workbook.add_worksheet(name: 'Making friends') do |sheet|
      MakingFriendsSheet.build(making_friends: making_friends, sheet: sheet)
    end

    package.serialize('facebook_analysis.xlsx')
  end
end

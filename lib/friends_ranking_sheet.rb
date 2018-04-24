# frozen_string_literal: true

class FriendsRankingSheet
  def self.build(ranking:, sheet:)
    sheet.add_row ['Friends ranking']
    sheet.add_row ['Rank', 'Friend name', 'total count', 'your messages count', 'friend messages count', 'your characters count', 'friend characters count', 'your words', 'friend words']
    rank = 1
    ranking.each do |friend_name, friend_data|
      sheet.add_row [rank, friend_name,
                     friend_data[:total_count], friend_data[:you_count],
                     friend_data[:friend_count], friend_data[:you_characters],
                     friend_data[:friend_characters], friend_data[:you_words],
                     friend_data[:friend_words]]
      rank += 1
    end
  end
end

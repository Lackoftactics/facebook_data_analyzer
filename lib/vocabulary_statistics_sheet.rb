# frozen_string_literal: true

class VocabularyStatisticsSheet
  def self.build(dictionary:, me:, most_popular_polish_words:, most_popular_english_words:, sheet:)
    sheet.add_row ['Vocabulary statistics']
    sheet.add_row ["You used #{dictionary.length} unique words and #{me[:total_words]} words in total"]

    most_popular_polish_words.each do |word|
      dictionary.delete(word)
    end

    most_popular_english_words.each do |word|
      dictionary.delete(word)
    end

    sheet.add_row ['This are cleaned results without most common english/polish words']
    sheet.add_row %w[Rank Word Occurences]

    words_ranked = dictionary.sort_by { |_word, count| count }.reverse[0..999]
    rank = 1
    words_ranked.each do |word, count|
      sheet.add_row [rank, word, count]
      rank += 1
    end
  end
end

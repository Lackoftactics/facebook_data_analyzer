# frozen_string_literal: true

# Retrieves the most popular words
class MostPopularWords
  def self.most_popular_polish_words
    @most_popular_polish_words ||= begin
                                File.open('most_popular_polish_words.txt').map do |line|
                                  line.split(' ')[0].downcase
                                end.compact
                              end
  end

  def self.most_popular_english_words
    @most_popular_english_words ||= begin
                                 File.open('most_popular_english_words.txt').map do |line|
                                   line.split(' ')[0].downcase
                                 end.compact
                               end
  end
end

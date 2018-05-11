# frozen_string_literal: true

module FacebookDataAnalyzer
  class Friends < Analyzeable
    include FacebookDataAnalyzer::ExportViewsMixin
    attr_reader :friends

    EXPORTS = [:making_friends].freeze

    # year, day_of_week, day, month: {#unit: count ...}
    # weekend: {weekend: count,
    #           weekday: count}
    # month_year: {#month - #year: count ...}
    # week_year: {#week - #year: count ...}
    COUNT_BY = %i[year day_of_week day month weekend month_year week_year].freeze

    def initialize(catalog:)
      @catalog = catalog
      @directory = "#{catalog}/html/"
      @file_pattern = 'friends.htm'
      @friends = []

      super()
    end

    def analyze
      Dir.chdir(@directory) do
        content = File.open(@file_pattern).read
        doc = Nokogiri::HTML(content)
        friends_list = doc.css('div.contents > ul')[0].css('li')

        friends_list.each do |friend_element|
          friend = Friend.parse(friend_element: friend_element)

          @friends << friend
          count(analyzeable: friend)
        end
      end
    end
  end
end

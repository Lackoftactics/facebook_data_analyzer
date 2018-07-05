# frozen_string_literal: true

module FacebookDataAnalyzer
  class Friends < Analyzeable
    attr_reader :friends
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

    def export(package:)
      making_friends_sheet(package: package)
    end

    private

    def making_friends_sheet(package:)
      package.workbook.add_worksheet(name: 'Making friends') do |sheet|
        sheet.add_row ['Making friends']
        sheet.add_row ['']

        sheet.add_row ['Making friends by year']
        sheet.add_row ['Year', 'Number of friends added']
        @counted_by[:year].sort_by { |year, _count| year }.each do |year, count|
          sheet.add_row [year, count]
        end

        sheet.add_row ['Making friends by week day']
        sheet.add_row ['Day of week', 'Number of friends added']
        @counted_by[:day_of_week].sort_by { |_day, count| count }.reverse.each do |day, count|
          sheet.add_row [day, count]
        end

        sheet.add_row ['Making friends by month']
        sheet.add_row ['Month', 'Number of friends added']
        @counted_by[:month].sort_by { |_month, count| count }.reverse.each do |month, count|
          sheet.add_row [month, count]
        end

        sheet.add_row ['Making friends on weekend vs. working days']
        sheet.add_row ['Working day or weekend', 'Number of friends added']
        @counted_by[:weekend].each do |type_of_day, count|
          sheet.add_row [type_of_day.to_s, count]
        end

        sheet.add_row ['Most busy weeks for making friends (week number and year)']
        sheet.add_row ['Week and year', 'Number of friends added']
        @counted_by[:week_year].sort_by { |_week_year, count| count }.reverse.each do |week_year, count|
          sheet.add_row [week_year, count]
        end

        sheet.add_row ['Most busy month-year by friends added']
        sheet.add_row ['Month year', 'Number of friends added']
        @counted_by[:month_year].sort_by { |_month_year, count| count }.reverse.each do |month_year, count|
          sheet.add_row [month_year, count]
        end

        sheet.add_row ['Most busy making friends days']
        sheet.add_row ['Day', 'Number of friends added']
        @counted_by[:day].sort_by { |_day, count| count }.reverse.each do |day, count|
          sheet.add_row [day, count]
        end
      end
    end
  end
end

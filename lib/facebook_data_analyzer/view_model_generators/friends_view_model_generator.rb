module FacebookDataAnalyzer
  class FriendsViewModelGenerator < ViewModelGenerator
    def making_friends_view_model
      sheet_name = 'Making Friends'
      model_meta = [['Making friends']]
      tables = []

      by_year = FacebookDataAnalyzer::Table.new(name: 'by_year')
      by_year.add_meta(['Making friends by year'])
      by_year.add_headers(['Year', 'Number of friends added'])
      @friends.counted_by[:year].sort_by {|year, _count| year}.each do |year, count|
        by_year.add_row([year, count])
      end
      tables << by_year

      by_weekday = FacebookDataAnalyzer::Table.new(name: 'by_weekday')
      by_weekday.add_meta(['Making friends by week day'])
      by_weekday.add_headers(['Day of week', 'Number of friends added'])
      @friends.counted_by[:day_of_week].sort_by {|_day, count| count}.reverse.each do |day, count|
        by_weekday.add_row([day, count])
      end
      tables << by_weekday

      by_month = FacebookDataAnalyzer::Table.new(name: 'by_month')
      by_month.add_meta(['Making friends by month'])
      by_month.add_headers(['Month', 'Number of friends added'])
      @friends.counted_by[:month].sort_by {|_month, count| count}.reverse.each do |month, count|
        by_month.add_row([month, count])
      end
      tables << by_month

      weekday_weekend = FacebookDataAnalyzer::Table.new(name: 'weekday_weekend')
      weekday_weekend.add_meta(['Making friends on weekend vs. working days'])
      weekday_weekend.add_headers(['Working day or weekend', 'Number of friends added'])
      @friends.counted_by[:weekend].each do |type_of_day, count|
        weekday_weekend.add_row([type_of_day.to_s, count])
      end
      tables << weekday_weekend

      by_weeks = FacebookDataAnalyzer::Table.new(name: 'by_weeks')
      by_weeks.add_meta(['Most busy weeks for making friends (week number and year)'])
      by_weeks.add_headers(['Week and year', 'Number of friends added'])
      @friends.counted_by[:week_year].sort_by {|_week_year, count| count}.reverse.each do |week_year, count|
        by_weeks.add_row([week_year, count])
      end
      tables << by_weeks

      by_month_year = FacebookDataAnalyzer::Table.new(name: 'by_month_year')
      by_month_year.add_meta(['Most busy month-year by friends added'])
      by_month_year.add_headers(['Month year', 'Number of friends added'])
      @friends.counted_by[:month_year].sort_by {|_month_year, count| count}.reverse.each do |month_year, count|
        by_month_year.add_row([month_year, count])
      end
      tables << by_month_year

      by_day = FacebookDataAnalyzer::Table.new(name: 'by_day')
      by_day.add_meta(['Most busy making friends days'])
      by_day.add_headers(['Day', 'Number of friends added'])
      @friends.counted_by[:day].sort_by {|_day, count| count}.reverse.each do |day, count|
        by_day.add_row([day, count])
      end
      tables << by_day

      build_view_model(model_name: sheet_name, meta: model_meta, tables: tables)
    end
  end
end
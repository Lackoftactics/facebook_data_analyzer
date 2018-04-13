class Friends
  GROUP_BY = [].freeze

  # year, day_of_week, day, month: {#unit: count ...}
  # weekend: {weekend: count,
  #           weekday: count}
  # month_year: {#month - #year: count ...}
  # week_year: {#week - #year: count ...}
  COUNT_BY = [:year, :day_of_week, :day, :month, :weekend, :month_year, :week_year].freeze

  def initialize(catalog:)
    @catalog = catalog
    @directory = "#{catalog}/html/"
    @file_pattern = 'friends.htm'
    @friends = []

    # Grouped by is weird and needs a hash for each GROUP_BY, hash for each unique group, and hash for attributes
    @grouped_by = Hash.new do |by_group, key|
      by_group[key] = Hash.new do |group_name, attribute|
        group_name[attribute] = Hash.new(nil)
      end
    end
    @counted_by = Hash.new { |hash, key| hash[key] = Hash.new(0) }
  end

  def analyze
    Dir.chdir(@directory) do
      content = File.open(@file_pattern).read
      doc = Nokogiri::HTML(content)
      friends_list = doc.css('div.contents > ul')[0].css('li')

      friends_list.each do |friend_element|
        friend_info = Friend.parse(friend_element: friend_element)
        friend = Friend.new(name: friend_info[:name], date_added: friend_info[:date_added])

        @friends << friend
        count!(analyzeable: friend)
      end
    end
  end

  def export(package:)
    making_friends_sheet(package: package)
  end

  private

  def group!(analyzeable:)
    GROUP_BY.each do |attribute|
      grouping_method = "group_by_#{attribute}".to_sym

      if analyzeable.respond_to?(grouping_method)
        grouped_analyzeable = analyzeable.send(grouping_method)

        grouped_analyzeable.each do |group, group_attributes|
          group_attributes.each do |group_attribute_key, group_attribute_value|
            current_grouping = @grouped_by[attribute][group][group_attribute_key]
            if current_grouping.nil?
              @grouped_by[attribute][group][group_attribute_key] = group_attribute_value
            else
              @grouped_by[attribute][group][group_attribute_key] += group_attribute_value
            end
          end
        end
      end
    end
  end

  def count!(analyzeable:)
    COUNT_BY.each do |attribute|
      counting_method = "count_by_#{attribute}".to_sym

      if analyzeable.respond_to?(counting_method)
        countables = analyzeable.send(counting_method)

        countables.each do |countable|
          @counted_by[attribute][countable] += 1
        end
      end
    end
  end

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
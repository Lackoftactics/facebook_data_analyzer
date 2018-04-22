# frozen_string_literal: true

class MessageStatisticsSheet
  def self.build(me:, messages_sent:, sheet:)
    sheet.add_row ['My message statistics']
    sheet.add_row ["You sent in total #{me[:total_message_count]} messages"]
    sheet.add_row ["You used #{me[:total_characters]} characters in total"]
    sheet.add_row ["You also used #{me[:total_words]} words in total"]
    sheet.add_row ["You also happened to use xD #{me[:total_xd]} times"]
    sheet.add_row ['']

    sheet.add_row ['Messaging by month']
    sheet.add_row ['Month', 'number of messages']

    messages_sent.by_month.sort_by { |_month, count| count }.each do |month, count|
      sheet.add_row [month, count]
    end

    sheet.add_row ['Messaging by year']
    sheet.add_row ['Year', 'number of messages']

    messages_sent.by_year.sort_by { |year, _count| year }.each do |year, count|
      sheet.add_row [year, count]
    end

    sheet.add_row ['Messaging by day of week']
    sheet.add_row ['Day of week', 'number of messages']

    messages_sent.by_day_of_week.sort_by { |_day, count| count }.reverse.each do |day, count|
      sheet.add_row [day, count]
    end

    sheet.add_row ['Messaging on week days vs. weekend']
    sheet.add_row ['Type of day', 'number of messages']

    messages_sent.by_weekend.each do |type, count|
      sheet.add_row [type, count]
    end

    sheet.add_row ['Breakdown of messages by hour']
    sheet.add_row ['Hour', 'number of messages']

    messages_sent.by_hour.sort_by { |hour, _count| hour }.each do |hour, count|
      sheet.add_row [hour, count]
    end

    sheet.add_row ['Breakdown of messages by hour and year']
    sheet.add_row ['Year and hour', 'number of messages']

    messages_sent.by_year_hour.sort_by { |year_hour, _count| y, h = year_hour.split(' - '); "#{y}0".to_i + h.to_i }.each do |year_hour, count|
      sheet.add_row [year_hour, count]
    end

    sheet.add_row ['Most busy messaging days']
    sheet.add_row ['Date', 'number of messages']

    messages_sent.by_date.sort_by { |_date, count| count }.reverse.each do |date, count|
      sheet.add_row [date, count]
    end
  end
end

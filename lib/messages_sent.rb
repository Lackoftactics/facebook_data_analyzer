# frozen_string_literal: true

class MessagesSent
  # analyze message patterns when messages are sent
  attr_accessor :by_month, :by_year, :by_day_of_week,
                :by_weekend, :by_date, :by_hour,
                :by_year_hour
  attr_reader :my_messages_dates

  def initialize(my_messages_dates)
    @my_messages_dates = my_messages_dates
    @by_month       = Hash.new(0)
    @by_year        = Hash.new(0)
    @by_day_of_week = Hash.new(0)
    @by_weekend     = Hash.new(0)
    @by_date        = Hash.new(0)
    @by_hour        = Hash.new(0)
    @by_year_hour   = Hash.new(0)
  end

  def build
    my_messages_dates.each do |date|
      by_month[date.strftime('%B')] += 1
      by_year[date.year] += 1
      by_day_of_week[date.strftime('%A')] += 1

      if date.friday? || date.saturday? || date.sunday?
        by_weekend[:weekend] += 1
      else
        by_weekend[:working] += 1
      end

      by_date[date.strftime('%F')] += 1
      by_hour[date.hour] += 1
      by_year_hour["#{date.year} - #{date.hour}"] += 1
    end
    self
  end
end

# frozen_string_literal: true

class MakingFriendsData
  # Creates the MakingFriendsData with help of FriendsDates
  attr_accessor :by_year, :by_week_day, :by_day,
                :by_month, :by_month_and_year, :by_weekend,
                :by_week_and_year
  attr_reader :friends_dates

  def initialize(friends_dates_data)
    @friends_dates         = friends_dates_data

    @by_year               = Hash.new(0)
    @by_week_day           = Hash.new(0)
    @by_day                = Hash.new(0)
    @by_month              = Hash.new(0)
    @by_month_and_year     = Hash.new(0)
    @by_weekend            = Hash.new(0)
    # @by_weekend_and_year = Hash.new(0)
    @by_week_and_year      = Hash.new(0)
  end

  def build
    friends_dates.each do |date|
      by_year[date.year] += 1
      by_week_day[date.strftime('%A')] += 1
      by_day[date.strftime('%F')] += 1
      by_month[date.strftime('%B')] += 1
      by_month_and_year[date.strftime('%B - %Y')] += 1
      by_week_and_year["week #{date.strftime('%V')} of #{date.year}"] += 1

      if date.friday? || date.saturday? || date.sunday?
        by_weekend[:weekend] += 1
      else
        by_weekend[:working] += 1
      end
    end
    self
  end
end

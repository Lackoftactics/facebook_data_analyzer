# frozen_string_literal: true

module FacebookDataAnalyzer
  class Friend
    attr_reader :name, :date_added

    def self.parse(friend_element:)
      friend_with_email = friend_element.text.match(/(.*)\s\((.*)\)\s\((.*)\)/)

      if friend_with_email
        name, date_added = friend_with_email.captures
      else
        name, date_added = friend_element.text.match(/(.*)\s\((.*)\)/).captures
      end

      date = if date_added == 'Today'
               Date.today
             elsif date_added == 'Yesterday'
               Date.today.prev_day
             else
               DateTime.parse(date_added)
             end

      Friend.new(name: name, date_added: date)
    end

    def initialize(name:, date_added:)
      @name = name
      @date_added = date_added
    end

    def count_by_year
      [@date_added.year]
    end

    def count_by_day_of_week
      [@date_added.strftime('%A')]
    end

    def count_by_day
      [@date_added.strftime('%F')]
    end

    def count_by_month
      [@date_added.strftime('%B')]
    end

    def count_by_weekend
      if @date_added.friday? || @date_added.saturday? || @date_added.sunday?
        [:weekend]
      else
        [:working]
      end
    end

    def count_by_month_year
      [@date_added.strftime('%B - %Y')]
    end

    def count_by_week_year
      ["week #{@date_added.strftime('%V')} of #{@date_added.year}"]
    end
  end
end

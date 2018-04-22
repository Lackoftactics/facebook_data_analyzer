# frozen_string_literal: true

class FriendsDates
  # analyze making of friends
  # Returns an array of [<Date>,<Date>]

  attr_reader :file
  attr_accessor :friends_dates

  def self.analyze(catalog)
    new(catalog).analyze
  end

  def initialize(catalog)
    @friends_dates = []
    @file = "#{catalog}/html/friends.htm"
  end

  def analyze
    friends_list.each do |friend_element|
      if friend_with_email(friend_element)
        _name, date_added = friend_with_email(friend_element).captures
      else
        _name, date_added = friend_element.text
                                          .match(/(.*)\s\((.*)\)/)
                                          .captures
      end

      date = if date_added == 'Today'
               Date.today
             elsif date_added == 'Yesterday'
               Date.today.prev_day
             else
               DateTime.parse(date_added)
             end

      friends_dates << date
    end
    self
  end

  def content
    File.open(file).read
  end

  def doc
    Nokogiri::HTML(content)
  end

  def friends_list
    doc.css('div.contents > ul')[0].css('li')
  end

  def friend_with_email(friend_element)
    friend_element.text.match(/(.*)\s\((.*)\)\s\((.*)\)/)
  end
end

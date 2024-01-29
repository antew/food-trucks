module Scraper
  def self.filter_by_date(schedule)
    schedule.select do |event|
      if event[:date].is_a?(Date)
        event[:date] >= Date.today
      else
        true
      end
    end
  end
end

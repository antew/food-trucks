require 'json'
require 'date'
require './scraper'
require 'nokogiri'

module CityStarBrewing
  include Scraper

  def self.schedule
    { location: 'City Star Brewing',
      calendar: Scraper.filter_by_date(data) }
  end

  def self.data
    file_path = "scrapes/city_star-#{Date.today.iso8601}.html"
    doc = nil

    unless File.exist?(file_path)
      puts 'Fetching again'
      `curl -L -o #{file_path} https://citystarbrewing.com/events/category/events/food-trucks/`
    end

    doc = Nokogiri::HTML(File.read(file_path))

    nodes = doc.css('.tribe-events-calendar-list__event-header')

    nodes.map do |node|
      truck = node.at('.tribe-events-calendar-list__event-title').text.strip
      date = node.css('.tribe-events-calendar-list__event-datetime').attribute('datetime').value
      start_time = node.css('.tribe-event-date-start').text.split('@').last.strip
      end_time = node.css('.tribe-event-time').text.strip

      { truck:,
        date: date ? Date.parse(date) : 'Unknown',
        time: "#{start_time} to #{end_time}" }
    end
  end
end

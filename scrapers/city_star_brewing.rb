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

    script_tags = doc.xpath('//script[@type="application/ld+json"]')
    event_data = []

    script_tags.each do |tag|
      begin
        parsed_data = JSON.parse(tag.content)
        if parsed_data.is_a?(Array)
          parsed_data.each do |item|
            event_data << item if item["@type"] == "Event"
          end
        end
      rescue JSON::ParserError => e
        puts "Json parsing error, skipping #{tag.inspect}"
        next
      end
    end

    event_data.map { |e| simplify_event(e) }
  end

  def self.simplify_event(event)
    start_time = DateTime.parse(event["startDate"])
    end_time = DateTime.parse(event["endDate"])
    {
      date: start_time.strftime("%Y-%m-%d"),
      truck: event["name"],
      time: "#{start_time.strftime('%l%p').strip}-#{end_time.strftime('%l%p').strip}"
    }
  end
end

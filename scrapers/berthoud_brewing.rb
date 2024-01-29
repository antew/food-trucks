require 'json'
require 'date'
require './scraper'

module BerthoudBrewing
  include Scraper

  def self.schedule
    { location: "Berthoud Brewing",
      calendar: Scraper.filter_by_date(data)
    }
  end

  def self.data
    JSON.load_file!('scrapes/berthoud_brewing.json')
      .map { |v| v.transform_keys!(&:to_sym) }
      .map { |v| v.merge({date: Date.parse(v[:date])}) }
  end
end

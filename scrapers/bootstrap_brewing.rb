require 'json'
require 'date'
require './scraper'

module BootstrapBrewing
  include Scraper

  def self.schedule
    { location: "Bootstrap Brewing",
      calendar: Scraper.filter_by_date(data)
    }
  end

  def self.data
    JSON.load_file!('scrapes/bootstrap_brewing.json')
      .map { |v| v.transform_keys!(&:to_sym) }
      .map { |v| v.merge({date: Date.parse(v[:date])}) }
  end
end

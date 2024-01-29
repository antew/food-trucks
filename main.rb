# frozen_string_literal: true

require 'date'
require 'json'
require 'erb'
require './scrapers/berthoud_brewing'
require './scrapers/bootstrap_brewing'
require './scrapers/city_star_brewing'

def build_schedules
  [CityStarBrewing, BerthoudBrewing, BootstrapBrewing].map(&:schedule)
end

def build_html(schedules)
  erb = ERB.new File.read('index.html.erb')
  erb.result binding
end

def write_index
  schedules = build_schedules
  File.write('index.html', build_html(schedules))
end

write_index

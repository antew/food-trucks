require 'nokogiri'
require 'date'
require 'json'
require 'erb'

def city_star_data
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

def berthoud_brewing_data
  JSON.load_file!('scrapes/berthoud_brewing.json').map { |v| v.transform_keys!(&:to_sym) }
end

def build_schedules
  [{ location: 'City Star Brewing', calendar: city_star_data },
   { location: 'Berthoud Brewing', calendar: berthoud_brewing_data }]
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

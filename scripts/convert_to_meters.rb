#!/usr/bin/env ruby

require 'json'
require 'parallel'
require 'ruby-progressbar'

def measure(start_point, end_point)
  lat1 = start_point[:lat] || start_point['lat']
  lon1 = start_point[:lon] || start_point['lon']
  lat2 = end_point[:lat] || end_point['lat']
  lon2 = end_point[:lon] || end_point['lon']

  # generally used geo measurement function
  radius = 6378.137
  # radius of earth in KM
  dLat = lat2 * Math::PI / 180 - (lat1 * Math::PI / 180)
  dLon = lon2 * Math::PI / 180 - (lon1 * Math::PI / 180)
  a = Math.sin(dLat / 2) * Math.sin(dLat / 2) + Math.cos(lat1 * Math::PI / 180) * Math.cos(lat2 * Math::PI / 180) * Math.sin(dLon / 2) * Math.sin(dLon / 2)
  c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
  d = radius * c
  d * 1000
end

if ARGV.length != 1
  puts <<EOF

convert_to_meters
-----------------

Convert latitude and longitude to meters of .save.json file

Example usage:

  convert_to_meters.rb postavarul.save.json
EOF
  exit 1
end

file_name = ARGV[0]

unless file_name.end_with? '.save.json'
  puts 'Need a *.save.json file created with to_json.rb'
  exit 2
end

@points = JSON.parse(File.read(file_name))

# get number of items per row
i = 0
last_lat = @points[0]['lat']
@items_per_row = 0
for point in @points
  if last_lat != point['lat']
    @items_per_row = i
    break
  end
  i += 1
end

def first_item_on_row_with target
  for point in @points
    if point['lat'] == target['lat']
      return point
    end
  end
end

def first_item_on_column_with target
  for point in @points
    if point['lon'] == target['lon']
      return point
    end
  end
end

i = 0
for point in @points
  point['index'] = i
  i += 1
end

converted = []

Parallel.each(
  @points,
  in_processes: Parallel.processor_count,
  progress: "Doing stuff",
  finish: -> (item, i, result) {
    converted.push result
  }
) do |point|
  lat = measure(point, first_item_on_row_with(point))
  lon = measure(point, first_item_on_column_with(point))
  { 'lat': lat, 'lon': lon, 'alt': point['alt'], 'index': point['index'] }
end

output_file = file_name.split('.').insert(1, 'converted2').join('.')
File.write(output_file, JSON.pretty_generate(converted))

# sorting converted doesn't work
items = JSON.parse(File.read(output_file))
items.sort! { |a,b| a['index'] <=> b['index'] }
File.write(output_file, JSON.pretty_generate(items))

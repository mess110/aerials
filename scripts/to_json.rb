#!/usr/bin/env ruby

require 'nokogiri'
require 'json'

if ARGV.length != 1
  puts <<EOF

to_json
-------

Convert gpx file with altitude to .save.json

Example usage:

  to_json.rb postavarul.gpx
EOF
  exit 1
end

file_name = ARGV[0]

unless file_name.end_with?('.gpx')
  puts 'need a gpx file with altitude'
  exit 2
end

doc = Nokogiri::XML(File.read(file_name))

points = []

doc.css('wpt').each do |asd|
  points.push({
    lat: asd.attr('lat').to_f,
    lon: asd.attr('lon').to_f,
    alt: asd.css('ele').text.to_f
  })
end

output_file = file_name.split('.')[0...-1].join('.') + '.save.json'
File.write(output_file, points.to_json)

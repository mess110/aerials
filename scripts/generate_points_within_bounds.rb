#!/usr/bin/env ruby

start_point = {
  lat: 45.5645,
  lon: 25.5588
}

end_point = {
  lat: 45.5703,
  lon: 25.5736
}

if ARGV.length != 4
  puts <<EOF

generate_points_within_bounds
-----------------------------

* Find points with the help of https://www.openstreetmap.org
* Run the script. It will create a output.gpx file
* Add elevation http://www.gpsvisualizer.com/elevation

Input explained:

                               end_point
                   +-----------+
                   |           |
                   |           |
                   |           |
                   +-----------+
        start_point

On OSM:

                         end_point[:lat]
                   +-----*-----+
                   |           |
 start_point[:lon] *           * end_point[:lon]
                   |           |
                   +-----*-----+
                         start_point[:lat]

Example usage:

  generate_points_within_bounds.rb #{start_point[:lat]} #{start_point[:lon]} #{end_point[:lat]} #{end_point[:lon]}

EOF
  exit 1
end

start_point[:lat] = ARGV[0].to_f
start_point[:lon] = ARGV[1].to_f
end_point[:lat] = ARGV[2].to_f
end_point[:lon] = ARGV[3].to_f

class Float
  def to_big_ass
    (self * 10000).to_i
  end
end

class Integer
  def to_small_ass
    self.to_f / 10000
  end
end

nodes = []

(start_point[:lat].to_big_ass..end_point[:lat].to_big_ass).each do |i|
  (start_point[:lon].to_big_ass..end_point[:lon].to_big_ass).each do |j|
    nodes.push({ lat: i.to_small_ass, lon: j.to_small_ass })
  end
end

# p nodes
output = <<EOF
<osm version="0.6" generator="Ruby Script" copyright="None" attribution="None" license="None">
  <bounds minlat="#{start_point[:lat]}" minlon="#{start_point[:lon]}" maxlat="#{end_point[:lat]}" maxlon="#{end_point[:lon]}"/>
EOF

nodes.each do |node|
 output += "  <node lat=\"#{node[:lat]}\" lon=\"#{node[:lon]}\"/>\n"
end

output += "</osm>"

File.write('output.gpx', output)

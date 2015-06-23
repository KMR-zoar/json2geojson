#!/usr/bin/env ruby
# coding: utf-8
require "json"

json_file_path = ARGV[0]

json_data = open(json_file_path) do |io|
   JSON.load(io)
end

geojson_data = {
   'type' => 'FeatureCollection',
   'crs' => {
      'type' => 'name',
      'properties' => {
         'name' => 'urn:ogc:def:crs:EPSG::2451'
      }
   },
   'features' => []
}

json_data['data'].each do |data|
   geojson_data['features'] << {
      'type' => 'Feature',
      'properties' => data,
      'geometry' => {
         'type' => 'Point',
         'coordinates' => [data['Ycoordinates'].to_f, data['Xcoordinates'].to_f]
         }
   }
end

geojson_file_path = json_file_path.gsub('.json','.geo.json')

open(geojson_file_path, 'w') do |io|
   JSON.dump(geojson_data, io)
end
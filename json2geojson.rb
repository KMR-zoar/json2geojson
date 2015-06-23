#!/usr/bin/env ruby
# coding: utf-8
require 'json'
require 'optparse'

#オプションの判定を行う
def options
   args = {}
   
   OptionParser.new do |parser|
      parser.on('-c VALUE', '--code VALUE', '座標系番号'){|v| args[:c] = v}
      parser.on('-i VALUE', '--input VALUE', 'JSONファイル(必須'){|v| args[:i] =v}
      parser.parse!(ARGV)
   end
   args
end

args = options

#JSONファイルの指定は必須、無ければスクリプトを終了する
unless args[:i]
   puts '読み込むJSONファイルが指定されていません'
   exit 1
end

json_file_path = args[:i]

#座標系番号が指定されていない場合は強制的に9系とする
unless args[:c]
   puts '座標系番号が指定されていません、9系として処理します。'
   args[:c] = '9'
end

#座標系番号をEPSGコードに変換する
code2epsg = [ nil, '2443', '2444', '2445', '2446', '2447', '2448', '2449', '2450', '2451', '2452', '2453', '2454', '2455', '2456', '2457', '2458', '2459', '2460', '2461']

epsg_code = code2epsg[args[:c].to_i]

unless epsg_code
   puts '座標系番号の指定が正しくありません。'
   exit 1
end

#南北方向のカラムを指定
#未実装

#東西方向のカラムを指定
#未実装

#指定されたJSONファイルの読み込み
json_data = open(json_file_path) do |io|
   JSON.load(io)
end

#GeoJSONの雛形を作成
geojson_data = {
   'type' => 'FeatureCollection',
   'crs' => {
      'type' => 'name',
      'properties' => {
         'name' => 'urn:ogc:def:crs:EPSG::' + epsg_code
      }
   },
   'features' => []
}

#GeoJSONの雛形にJSONファイルのデータを投入する
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

#GeoJSONファイルの書き出し
geojson_file_path = json_file_path.gsub('.json','.geojson')

open(geojson_file_path, 'w') do |io|
   JSON.dump(geojson_data, io)
end

exit 0
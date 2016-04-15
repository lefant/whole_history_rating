require 'json'
require 'net/http'

file = File.read('test/games.json')
games = JSON.parse(file)

req = Net::HTTP::Post.new('/games', 'Content-Type' => 'application/json')
req.body = games.to_json
response = Net::HTTP.new('localhost', '8080').start { |http| http.request(req) }
puts "Response #{response.code} #{response.message}: #{response.body}"

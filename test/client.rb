require 'json'
require 'net/http'

# host = 'localhost'
# port = 8080
host = 'whole-history-rating.herokuapp.com'
port = 80

file = File.read('test/games.json')
games = JSON.parse(file)

req = Net::HTTP::Post.new('/games', 'Content-Type' => 'application/json')
req.body = games.to_json
response = Net::HTTP.new(host, port).start { |http| http.request(req) }
puts "Response #{response.code} #{response.message}: #{response.body}"

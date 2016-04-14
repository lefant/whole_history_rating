require 'date'
require 'sinatra'
require 'whole_history_rating'
require 'yajl'

@whr = WholeHistoryRating::Base.new(w2: 300)

get '/' do
  'Just Do It'
end

get '/example.json' do
  content_type :json
  { key1: 'value1', key2: 'value2' }.to_json
end

post '/games' do
  request.body.rewind
  days = Yajl::Parser.parse(request.body.read) do |game|
    puts 'game', game
    puts 'game date', game['date']
    puts Date.parse(game['date']).jd
  end
  min_day = days.min - 1

  games.reverse_each do |game|
    day = Date.parse(game['date']).jd - min_day
    summary = game['summary']
    w = summary['winners_text']
    l = summary['loosers_text']
    # WholeHistoryRating::Base#create_game arguments:
    # black player name, white player name, winner, day number, handicap
    @whr.create_game(w, l, 'B', day, 0)
  end

  # Iterate the WHR algorithm towards convergence with more players/games,
  # more iterations are needed.
  @whr.iterate(100)

  @whr.players.each do |p|
    rs = @whr.ratings_for_player(p)
    if p.include? ','
      puts 'skipping player including , ', p
    else
      if rs.count > 1
        rs.each do |r|
          # csv << ['player', 'day_number', 'elo_rating', 'uncertainty']
          puts [p].concat(r)
        end
      end
    end
  end

  return_message = { status: :ok }
  return_message.to_json
end

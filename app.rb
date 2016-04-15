require 'date'
require 'json'
require 'sinatra'
require 'whole_history_rating'

post '/games' do
  request.body.rewind
  games = JSON.parse request.body.read

  @whr = WholeHistoryRating::Base.new(w2: 300)

  def create_game(min_day, game)
    day = Date.parse(game['date']).jd - min_day
    summary = game['summary']
    w = summary['winners_text']
    l = summary['loosers_text']
    # WholeHistoryRating::Base#create_game arguments:
    # black player name, white player name, winner, day number, handicap
    @whr.create_game(w, l, 'B', day, 0)
  end

  min_day = get_min_day(games)
  games.reverse_each do |game|
    create_game(min_day, game)
  end

  # Iterate the WHR algorithm towards convergence with more players/games,
  # more iterations are needed.
  @whr.iterate(100)

  single_players = @whr.players.reject { |p| p.include? ',' }
  ratings = single_players.flat_map do |p, k|
    rs = @whr.ratings_for_player(p)
    rs.map do |r|
      { player: p, day: r[0], elo: r[1], uncertainty: r[2] }
    end
  end

  ratings.to_json
end

def get_min_day(games)
  days = games.map do |game|
    Date.parse(game['date']).jd
  end
  days.min - 1
end

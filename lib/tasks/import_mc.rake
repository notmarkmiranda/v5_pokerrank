require 'csv'
require 'net/http'
require 'uri'

desc 'import mike-cassano'
task import_mc: [:environment] do
  user = User.find_or_create_by(email: 'markmiranda51@gmail.com')
  user.update(password: 'password1234')

  league = user.leagues.find_or_create_by(name: "Mike Cassano's Super Fun Leage")
  puts "Created #{league.name}!"
  season_01 = league.seasons.last

  uri = URI.parse('https://docs.google.com/spreadsheets/d/e/2PACX-1vQsxani6LWbWj1o1LzK8U--98RnBOP5QhIfhSxdkls-8vzUhkPyGlT36prttjrm9dykS2U1680k_QOA/pub?gid=0&single=true&output=csv')

  csv_01 = Net::HTTP.get(uri)
  CSV.parse(csv_01, { :row_sep => :auto, headers: true, header_converters: :symbol }) do |row|
    first_name, last_name = row[:person].split(" ")
    date = Date.strptime(row[:date], '%m/%d/%Y')

    participant = Participant.find_or_create_by(first_name: first_name, last_name: last_name, user_id: user.id)
    game = season_01.games.find_or_create_by(date: date, buy_in: 15, completed: true)
    player = game.players.create(participant_id: participant.id,
                                 finishing_place: row[:place],
                                 additional_expense: row[:additional],
                                 score: row[:score])

    puts "#{player.full_name} finished #{player.finishing_place.ordinalize} in Game ##{game.id} on #{game.formatted_date}."
  end

  puts "Season #1 - #{season_01.games.count} games!"

  season_02 = league.seasons.create
  uri_02 = URI.parse('https://docs.google.com/spreadsheets/d/e/2PACX-1vQsxani6LWbWj1o1LzK8U--98RnBOP5QhIfhSxdkls-8vzUhkPyGlT36prttjrm9dykS2U1680k_QOA/pub?gid=842704448&single=true&output=csv')

  csv_02 = Net::HTTP.get(uri_02)

  CSV.parse(csv_02, { :row_sep => :auto, headers: true, header_converters: :symbol }) do |row|
    first_name, last_name = row[:person].split(" ")
    date = Date.strptime(row[:date], '%m/%d/%Y')

    participant = Participant.find_or_create_by(first_name: first_name, last_name: last_name, user_id: user.id)
    game = season_02.games.find_or_create_by(date: date, buy_in: 15, completed: true)
    player = game.players.create(participant_id: participant.id,
                                  finishing_place: row[:place],
                                  additional_expense: row[:additional],
                                  score: row[:score])

    puts "#{player.full_name} finished #{player.finishing_place.ordinalize} in Game ##{game.id} on #{game.formatted_date}."
  end

  puts "Season #2 - #{season_02.games.count} games!"
end

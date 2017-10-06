class Participant < ApplicationRecord
  include NumberHelper
  validates_presence_of :first_name
  validates_presence_of :last_name
  validates_presence_of :user_id

  belongs_to :user
  has_many :players
  has_many :games, through: :players

  def attendance_percentage(league)
    games_count / league.games_count.to_f * 100
  end

  def finishing_place_in_game(game)
    players.where(game_id: game.id).first.finishing_place
  end

  def first_or_second_in_game?(game)
    place = finishing_place_in_game(game)
    place == 1 || place == 2
  end

  def full_name
    "#{first_name.titleize} #{last_name.titleize}"
  end

  def games_by_season(season)
    games.where(season_id: season.id)
  end

  def games_count
    games.count
  end

  def nemesis(game)
    if finishing_place_in_game(game) == 1
      game.second_place_participant
    else
      game.first_place_participant
    end
  end

  def place_finishes_by_season(season, place)
    players.joins(:game).where("games.season_id = ? AND finishing_place IN (?)", season.id, place).count
  end

  def place_finishes_overall(place)
    players.joins(:game).where('finishing_place IN (?)', place).count
  end

  def played_in_by_season(season)
    games_by_season(season).count
  end

  def played_in_by_season_percentage(season)
    (played_in_by_season(season) / season.games_count.to_f) * 100
  end

  def ordinal_by_season(season)
    (Participant.ordered_by_total_score_by_season(season.id).index(self) + 1).ordinalize
  end

  def overall_place_percentage
    place_finishes_overall([2, 3]) / games_count.to_f * 100
  end

  def overall_win_percentage
    place_finishes_overall(1) / games_count.to_f * 100
  end

  def player_since
    games.limit(1).sort_by(&:date).first.month_year
  end

  def reversed_games_by_season(season)
    games_by_season(season).reverse
  end

  def reversed_seasons
    games.collect(&:season).uniq.reverse
  end

  def score_by_game(game)
    players.where(game_id: game.id).first.score
  end

  def season_score(season_id)
    players.joins(:game).where("games.season_id = ?", season_id)
      .limit(9)
      .order("score desc")
      .sum(&:score)
  end

  def season_place_percentage(season)
    place_finishes_by_season(season, [2, 3]) / played_in_by_season(season).to_f * 100
  end

  def season_win_percentage(season)
    place_finishes_by_season(season, 1) / played_in_by_season(season).to_f * 100
  end

  def self.ordered_by_total_score_by_season(season_id)
    parts = joins(:games).where("games.season_id = ?", season_id).uniq
    parts.sort_by { |part| part.season_score(season_id) }.reverse
  end

  def won_or_placed_in_by_season(season)
    players.joins(:game).where("finishing_place IN (?) AND games.season_id= ?", [1, 2, 3], season.id).count
  end

  def won_or_placed_in_by_season_percentage(season)
    decimal_to_two_digits(won_or_placed_in_by_season(season) / played_in_by_season(season).to_f)
  end
end

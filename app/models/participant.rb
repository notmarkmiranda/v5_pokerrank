class Participant < ApplicationRecord
  include NumberHelper
  validates_presence_of :first_name
  validates_presence_of :last_name
  validates_presence_of :user_id

  belongs_to :user
  has_many :players
  has_many :games, through: :players

  def place_finishes_by_season(season, place)
    players.joins(:game).where("games.season_id = ? AND finishing_place IN (?)", season.id, place).count
  end

  def full_name
    "#{first_name.titleize} #{last_name.titleize}"
  end

  def played_in_by_season(season)
    players.joins(:game).where("games.season_id = ?", season.id).count
  end

  def played_in_by_season_percentage(season)
    (played_in_by_season(season) / season.games_count.to_f) * 100
  end

  def season_score(season_id)
    players.joins(:game).where("games.season_id = ?", season_id)
      .limit(9)
      .order("score desc")
      .sum(&:score)
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

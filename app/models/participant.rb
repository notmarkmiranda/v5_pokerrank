class Participant < ApplicationRecord
  include NumberHelper
  validates_presence_of :first_name
  validates_presence_of :last_name
  validates_presence_of :user_id

  belongs_to :user
  has_many :players

  def full_name
    "#{first_name.titleize} #{last_name.titleize}"
  end

  def played_in_by_season(season)
    players.joins(:game).where("games.season_id = ?", season.id).count
  end

  def won_or_placed_in_by_season(season)
    players.joins(:game).where("finishing_place IN (?) AND games.season_id= ?", [1, 2, 3], season.id).count
  end

  def won_or_placed_in_by_season_percentage(season)
    decimal_to_two_digits(won_or_placed_in_by_season(season) / played_in_by_season(season).to_f)
  end
end

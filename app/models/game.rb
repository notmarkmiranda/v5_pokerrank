class Game < ApplicationRecord
  validates_presence_of :date
  validates_presence_of :buy_in
  validates_presence_of :season_id

  belongs_to :season
  delegate :league, to: :season
  has_many :players
end

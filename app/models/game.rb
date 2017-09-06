class Game < ApplicationRecord
  validates_presence_of :date
  validates_presence_of :buy_in
  validates_presence_of :season_id

  belongs_to :season
  delegate :league, to: :season
  has_many :players

  default_scope { order(date: :asc) }

  def formatted_date
    date.strftime('%B %e, %Y')
  end

  def players_or_attendees
    completed ? players.count : attendees
  end
end

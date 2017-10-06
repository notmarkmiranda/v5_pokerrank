class Game < ApplicationRecord
  validates_presence_of :date
  validates_presence_of :buy_in
  validates_presence_of :season_id

  belongs_to :season
  delegate :league, to: :season
  has_many :players

  default_scope { order(date: :asc) }

  def any_finished_players?
    finished_players.any?
  end

  def finished_players
    players.where.not(finishing_place: nil)
  end

  def first_place_participant
    players.where(finishing_place: 1).first.participant
  end

  def formatted_date
    date.strftime('%B %e, %Y')
  end

  def month_year
    date.strftime('%B %Y')
  end

  def number_by_season(season)
    season.games.index(self) + 1
  end

  def players_count
    players.count
  end

  def players_or_attendees
    completed ? players.count : attendees
  end

  def players_ordered_by_finishing_place
    players.sort_by(&:finishing_place)
  end

  def pot_size
    if completed
      (players.count * buy_in) + total_additional_expense
    else
    end
  end

  def runner_up
    player_in_place(2)
  end

  def second_place_participant
    players.where(finishing_place: 2).first.participant
  end

  def winner
    player_in_place(1)
  end

  private

  def additional_expense
    players.pluck(:additional_expense).compact.reduce(:+)
  end

  def player_in_place(place)
    players.where(finishing_place: place).first.participant
  end

  def total_additional_expense
    additional_expense.nil? ? 0 : additional_expense
  end
end

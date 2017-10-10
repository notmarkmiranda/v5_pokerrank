class Season < ApplicationRecord
  validates :league_id, presence: true

  belongs_to :league
  has_many :games
  has_many :players, through: :games

  after_commit :deactivate_other_seasons
  default_scope { order(created_at: :asc) }
  scope :reverse_order, -> { order(created_at: :desc) }

  def average_pot_size
    total_pot / games_count.to_f
  end

  def beginning_of_season
    games.first.formatted_date
  end

  def biggest_game
    games.max_by(&:pot_size)
  end

  def end_of_season
    is_active? ? "still in progress" : games.last.formatted_date
  end

  def first_game
    games.first
  end

  def games_count
    games.count
  end

  def has_first_game?
    games.any?
  end

  def has_last_game?
    games.count > 1 && active == false
  end

  def last_game
    games.last
  end

  def number_by_league(league)
    number = league.ordered_seasons_by_game_date.index(self)
    number.nil? ? 0 : number + 1
  end

  def players_per_game
    players.count / games_count.to_f
  end

  def reversed_games
    games.sort_by(&:date).reverse
  end

  def season_leader(index=0)
    score_hash = get_scores
    reduced_scores = reduce_scores(score_hash)
    get_leader(reduced_scores, index) unless reduced_scores.keys.empty?
  end

  def season_number
    league.seasons.index(self) + 1
  end

  def season_start_date
    games.sort_by(&:date).first.formatted_date
  end

  def total_pot
    games.sum(&:pot_size)
  end

  def unique_players_count
    players.pluck(:participant_id).uniq.count
  end

  private

  def deactivate_other_seasons
    Season.where.not(id: self.id).update_all(active: false)
  end

  def get_leader(scores, index)
    value = scores.max_by { |id, score| score }[index]

    return Participant.find(value) if index == 0
    return value if index == 1
  end

  def get_scores
    players.each_with_object({}) do |obj, hash|
      hash[obj.participant_id] = [] if hash[obj.participant_id].nil?
      hash[obj.participant.id] << obj.score
    end
  end

  def is_active?
    active == true
  end

  def reduce_scores(score_hash)
    score_hash.each_with_object({}) do |obj, hash|
      hash[obj[0]] = obj[1].max(9).reduce(:+)
    end
  end
end

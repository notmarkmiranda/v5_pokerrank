class Season < ApplicationRecord
  validates :league_id, presence: true

  belongs_to :league
  has_many :games
  has_many :players, through: :games

  after_commit :deactivate_other_seasons
  default_scope { order(created_at: :asc) }

  def biggest_game
    games.max_by(&:pot_size)
  end

  def games_count
    games.count
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

  def reduce_scores(score_hash)
    score_hash.each_with_object({}) do |obj, hash|
      hash[obj[0]] = obj[1].max(9).reduce(:+)
    end
  end
end

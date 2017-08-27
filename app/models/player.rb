class Player < ApplicationRecord
  validates_presence_of :participant_id
  validates_presence_of :game_id
  validates_uniqueness_of :participant_id, scope: :game_id

  belongs_to :participant
  belongs_to :game
  delegate :user, to: :participant
  delegate :league, to: :game
end

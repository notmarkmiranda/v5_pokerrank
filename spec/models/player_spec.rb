require 'rails_helper'

describe Player, type: :model do
  context 'validations' do
    it { should validate_presence_of :participant_id }
    it { should validate_presence_of :game_id }
    it 'player is scoped to a participant and game' do
      create(:player)
      should validate_uniqueness_of(:participant_id).scoped_to(:game_id)
    end
  end

  context 'relationships' do
    it { should belong_to :participant }
    it { should belong_to :game }
  end
end

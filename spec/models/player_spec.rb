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
    it 'should belong to a user' do
      user = create(:user)
      participant = create(:participant, user: user)
      player = create(:player, participant: participant)
      expect(player.user).to eq(user)
    end

    it 'should belong to a league' do
      league = create(:league)
      season = league.seasons.first
      game = create(:game, season:season)
      player = create(:player, game: game)

      expect(player.league).to eq(league)
    end
  end

  context 'methods' do
    before do
      participant = create(:participant, first_name: 'Doyle', last_name: 'Brunson')
      @player = create(:player, participant: participant)
    end

    context '#full_name' do
      it 'returns the full name of the participant' do
        expect(@player.full_name).to eq('Doyle Brunson')
      end
    end

    context '#total_expense' do
      it 'returns the total expense of the player' do
        expect(@player.total_expense).to eq(200)
      end

      it 'returns the total expense of the player with an additional_expense' do
        @player.update(additional_expense: 200)
        expect(@player.total_expense).to eq(300)
      end
    end
  end
end

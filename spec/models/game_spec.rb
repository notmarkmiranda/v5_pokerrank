require 'rails_helper'

describe Game, type: :model do
  context 'validations' do
    it { should validate_presence_of :date }
    it { should validate_presence_of :buy_in }
    it { should validate_presence_of :season_id }
  end

  context 'relationships' do
    it { should belong_to :season }
    it 'should have a league' do
      league = create(:league)
      game = create(:game, season: league.seasons.first)
      expect(game.league).to eq(league)
    end
    it { should have_many :players }
  end

  context 'methods' do
    before do
      @game = create(:game)
    end

    context '#any_finished_players?' do
      it 'true' do
        create(:player, game: @game, finishing_place: 1)
        expect(@game.any_finished_players?).to eq true
      end

      it 'false' do
        expect(@game.any_finished_players?).to eq false
      end
    end

    context '#finished_players' do
      it 'returns an empty array' do
        expect(@game.finished_players).to eq([])
      end

      it 'returns an array of finished players' do
        player1, player2 = create_list(:player, 2, game: @game, finishing_place: 1)
        expect(@game.finished_players).to eq([player1, player2])
      end

      it 'games are players are exclusive to each other' do
        game2 = create(:game)
        player1, player2 = create_list(:player, 2, game: @game, finishing_place: 1)
        expect(game2.finished_players).to eq([])
        expect(@game.finished_players).to eq([player1, player2])
      end
    end

    context '#first_place_participant' do
      before do
        @participant = create(:participant)
      end

      it 'returns the participant in first place' do
        create(:player, finishing_place: 1, participant_id: @participant.id, game: @game)
        expect(@game.first_place_participant).to eq @participant
      end

      it 'returns nil if there are no finished players' do
        expect(@game.first_place_participant).to be nil
      end
    end
  end
end

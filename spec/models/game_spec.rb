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
      it 'returns true' do
        create(:player, game: @game, finishing_place: 1)
        expect(@game.any_finished_players?).to eq true
      end

      it 'false' do
        expect(@game.any_finished_players?).to eq false
      end
    end

    context '#calculate_scores' do
      before do
        @game.update(buy_in: 20)
        10.times do |x|
          create(:player, game: @game, finishing_place: x + 1, additional_expense: 0)
        end
      end

      it 'calculates scores for a game' do
        @game.calculate_scores
        expect(@game.players.where(finishing_place: 1).first.score).to eq(7.07)
        expect(@game.players.where(finishing_place: 10).first.score).to eq(1.28)
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

      it 'returns nil if there is not a 1st place player' do
        create(:player, finishing_place: 2, participant_id: @participant.id, game: @game)
        expect(@game.first_place_participant).to be nil
      end
    end

    context '#formated_date & #month_year' do
      before do
        @game.update(date: Date.new(2015, 01, 01))
      end

      it 'returns a formatted date' do
        expect(@game.formatted_date).to eq('January 1, 2015')
      end

      it 'returns month and year' do
        expect(@game.month_year).to eq('January 2015')
      end
    end

    context '#number_by_season' do
      before do
        @game2 = create(:game, season: @game.season)
      end

      it 'returns 1 for the first game' do
        expect(@game.number_by_season).to eq(1)
      end

      it 'returns 2 for the second game' do
        expect(@game2.number_by_season).to eq(2)
      end
    end

    context '#players_count' do
      it 'returns 0 for no players' do
        expect(@game.players_count).to eq(0)
      end

      it 'returns 1 for a single player' do
        create(:player, game: @game)
        expect(@game.players_count).to eq(1)
      end

      it 'returns 2 for a two players' do
        create_list(:player, 2, game: @game)
        expect(@game.players_count).to eq(2)
      end
    end

    context '#players_or_attendees' do
      it 'returns game attendees for an incomplete game' do
        expect(@game.players_or_attendees).to eq(10)
      end

      it 'returns players count for a completed game' do
        @game.update(completed: true)
        create_list(:player, 5, game: @game)
        expect(@game.players_or_attendees).to eq(5)
      end
    end

    context '#players_ordered_by_finishing_place' do
      before do
        p1 = create(:player, game: @game, finishing_place: 2)
        p2 = create(:player, game: @game, finishing_place: 3)
        p3 = create(:player, game: @game, finishing_place: 1)
        @ordered = [p3, p1, p2]
      end

      it 'returns the players in order' do
        expect(@game.players_ordered_by_finishing_place).to eq(@ordered)
      end
    end

    context '#pot_size' do
      it 'for a completed game' do
        create_list(:player, 3, game: @game)
        @game.update(completed: true)
        expect(@game.pot_size).to eq(600)
      end

      it 'for an incomplete game' do
        @game.update(completed: false)
        expect(@game.pot_size).to eq(1000)
      end
    end

    context '#runner_up' do
      it 'returns the second place participant' do
        player2 = create(:player, finishing_place: 2, game: @game)
        expect(@game.runner_up).to eq(player2.participant)
      end

      it 'returns nil if there is no second place player' do
        create(:player, finishing_place: 1, game: @game)
        create(:player, finishing_place: 3, game: @game)
        expect(@game.runner_up).to be nil
      end
    end

    context '#winner' do
      it 'returns the first place participant' do
        player = create(:player, finishing_place: 1, game: @game)
        expect(@game.winner).to eq(player.participant)
      end

      it 'returns nil if there is no first place participant' do
        create(:player, finishing_place: 2, game: @game)
        create(:player, finishing_place: 3, game: @game)
        expect(@game.winner).to be nil
      end
    end
  end
end

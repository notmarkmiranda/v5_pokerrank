require 'rails_helper'

describe Season, type: :model do
  context 'validations' do
    it { should validate_presence_of :league_id }
  end

  context 'relationships' do
    it { should belong_to :league }
    it { should have_many :games }
    it { should have_many(:players).through(:games) }
  end

  context 'methods' do
    before do
      @league = create(:league)
      @season = @league.seasons.first
    end

    it 'only one active season - create' do
      @league.seasons.create

      expect(@season.reload.active).to eq(false)
    end

    it 'only one active season - update' do
      @league.seasons.create
      @league.seasons.create
      season = Season.where(active: false).last
      season.update(active: true)

      expect(Season.where(active:false).include?(season)).to be false
    end

    context 'multiple games & players' do
      before do
        game_1, @game_2 = create_list(:game, 2, season: @season)
        create_list(:player, 10, game: game_1)
        create_list(:player, 12, game: @game_2)
        Game.update_all(completed: true)
      end

      it '#average_pot_size' do
        expect(@season.average_pot_size).to eq(2200.0)
      end

      it '#biggest_game' do
        expect(@season.biggest_game).to eq(@game_2)
      end

      it '#games_count' do
        expect(@season.games_count).to eq 2
      end

      it '#players_per_game' do
        expect(@season.players_per_game).to eq 11
      end

      it '#season_number' do
        expect(@season.season_number).to eq 1
      end
    end


    it '#season_leader'
    it '#season_start_date'
    it '#total_pot'

  end
end

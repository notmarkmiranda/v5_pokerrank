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
        @game_1, @game_2 = create_list(:game, 2, season: @season)
        create_list(:player, 10, game: @game_1)
        create_list(:player, 12, game: @game_2)
        Game.update_all(completed: true)
      end

      context '#average_pot_size' do
        it 'returns the average pot size of the games in the season' do
          expect(@season.average_pot_size).to eq(2200.0)
        end
      end

      context '#beginning_of_season & #end_of_season' do
        it 'returns nil for a season without game' do
          new_season = create(:season, league: @league)
          expect(new_season.beginning_of_season).to be nil
					expect(new_season.end_of_season).to be nil
        end

				it 'returns "still in progress" for an active season' do
          expect(@season.end_of_season).to eq('still in progress')
				end

        it 'returns the end of the season for an inactive season' do
          @game_2.update(date: Date.new(2017, 7, 14))
          @season.update(active: false)
          expect(@season.end_of_season).to eq('July 14, 2017')
        end

        it 'returns the beggining of the season' do
          @game_2.update(date: Date.new(1981, 12, 06))
          expect(@season.beginning_of_season).to eq('December 6, 1981')
        end
      end

      context '#biggest_game' do
        it 'returns the biggest game of the season' do
          expect(@season.biggest_game).to eq(@game_2)
        end
      end

      context '#first_game' do
        it 'returns the first game' do
          expect(@season.first_game).to eq(@game_1)
        end
      end

      context '#games_count' do
        it 'returns the number of games' do
          expect(@season.games_count).to eq 2
        end
      end

      context '#has_first_game?' do
        it 'returns false if there is no first game' do
          new_season = create(:season, league: @league)
          expect(new_season.has_first_game?).to be false
        end

        it 'returns true if there is a first game' do
          expect(@season.has_first_game?).to be true
        end
      end

      context '#has_last_game?' do
        before do
          @new_season = create(:season, league: @league, active: false)
        end

        it 'returns false when there are 0 games' do
          expect(@new_season.has_last_game?).to be false
        end

        it 'returns false when there is 1 game' do
          create(:game, season: @new_season)
          expect(@new_season.has_last_game?).to be false
        end

        it 'returns false when active is true' do
          create_list(:game, 2, season: @new_season)
          @new_season.update(active: true)
          expect(@new_season.has_last_game?).to be false
        end

        it 'returns true when there are 2 games and active is false' do
          create_list(:game, 2, season: @new_season)
          @new_season.update(active: false)
          expect(@new_season.has_last_game?).to be true
        end
      end

      context '#last_game' do
        it 'returns nil for no games' do
          new_season = create(:season, league: @league)
          expect(new_season.last_game).to be nil
        end

        it 'returns the last game' do
          game = create(:game, date: Date.new(2020, 1,1), season: @season)
          expect(@season.last_game).to eq(game)
        end
      end

      context '#number_by_league' do
        before do
          @new_season = create(:season, league: @league)
        end

        it 'returns 0 for a league with no games' do
          expect(@new_season.number_by_league(@league)).to eq(0)
        end

        it 'returns the number for a league with games' do
          create(:game, season: @new_season)
          expect(@season.number_by_league(@league)).to eq(1)
          expect(@new_season.number_by_league(@league)).to eq(2)
        end
      end

      context '#players_per_game' do
        it 'returns 0 for no games' do
          new_season = create(:season, league: @league)
          expect(new_season.players_per_game).to eq(0)
        end

        it 'returns the average number of players per game' do
          expect(@season.players_per_game).to eq(11)
        end
      end

      context '#reversed_games' do
        it 'returns an empty array for no games' do
          new_season = create(:season)
          expect(new_season.reversed_games).to eq([])
        end

        it 'returns the games in a reversed order' do
          expect(@season.reversed_games).to eq([@game_2, @game_1])
        end
      end

      context '#season_leader' do
        it 'returns nil if no season leader' do
          new_season = create(:season)
          expect(new_season.season_leader).to be nil
        end

        it 'returns the season leader' do
          expect(@season.season_leader).to eq(Participant.first)
        end

        it 'returns the person who played more games if tied' #unsure if this is doable
      end

      it '#season_number' do
        expect(@season.season_number).to eq 1
      end

      context '#season_start_date' do
        it 'returns nil for no games' do
          new_season = create(:season)
          expect(new_season.season_start_date).to be nil
        end

        it 'returns the date for a seasons first game' do
          @game_1.update(date: Date.new(1981, 12, 6))
          expect(@season.season_start_date).to eq("December 6, 1981")
        end
      end

      context '#total_pot' do
        it 'returns 0 for no games in a season' do
          new_season = create(:season)
          expect(new_season.total_pot).to eq(0)
        end
        it 'returns the total pot for a season' do
          expect(@season.total_pot).to eq(4400)
        end
      end

      context '#unique_players_count' do
        it 'returns 0 for no games with any players' do
          new_season = create(:season)
          expect(new_season.unique_players_count).to eq(0)
        end

        it 'returns the number of unique players' do
          expect(@season.unique_players_count).to eq(22)
        end
      end
    end
  end
end

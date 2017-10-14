require 'rails_helper'

describe League, type: :model do
  context 'validations' do
    it { should validate_presence_of :name }
    it { should validate_uniqueness_of :name }
    it { should validate_presence_of :slug }
    it { should validate_presence_of :user_id }
  end

  context 'relationships' do
    it { should belong_to :user }
    it { should have_many :seasons }
    it { should have_many(:games).through(:seasons) }
    it { should have_many(:players).through(:games) }
  end

  context 'methods' do
    before do
      @league = create(:league)
    end

    context '#active_season' do
      it 'returns the active season' do
        active_season = @league.seasons.first
        expect(@league.active_season).to eq(active_season)
      end

      it 'returns nil if there is no active season' do
        create(:season, league: @league)
        Season.update_all(active: false)
        expect(@league.active_season).to be nil
      end
    end

    context '#completed_games_count & #games_count' do
      it 'returns 0 for no completed games' do
        expect(@league.completed_games_count).to eq(0)
        expect(@league.games_count).to eq(0)
      end

      it 'returns 1 for one completed game' do
        create(:game, completed: true, season: @league.active_season)
        create(:game, completed: false, season: @league.active_season)
        expect(@league.completed_games_count).to eq(1)
        expect(@league.games_count).to eq(2)
      end

      it 'returns 2 for two completed games' do
        create_list(:game, 2, completed: true, season: @league.active_season)
        create_list(:game, 50, completed: false, season: @league.active_season)
        expect(@league.completed_games_count).to eq(2)
        expect(@league.games_count).to eq(52)
      end
    end

    context '#has_uncompleted_game?' do
      it 'returns true for an uncompleted game' do
        create(:game, completed: true, season: @league.active_season)
        create(:game, completed: false, season: @league.active_season)
        expect(@league.has_uncompleted_game?).to eq(true)
      end

      it 'returns false when no games are incomplete' do
        create_list(:game, 5, completed: true, season: @league.active_season)
        expect(@league.has_uncompleted_game?).to eq(false)
      end
    end

    context '#has_active_season?' do
      it 'returns true when a season is active' do
        expect(@league.has_active_season?).to eq(true)
      end

      it 'returns false when no seasons are active' do
        Season.update_all(active: false)
        expect(@league.has_active_season?).to eq(false)
      end
    end

    context '#ordered_seasons_by_game_date' do
      it 'returns ordered seasons by game date' do
        create(:game, date: Date.new(2015, 01, 01), season: @league.active_season)
        season_1 = @league.active_season
        season_2 = create(:season, league: @league)
        create(:game, date: Date.new(2014, 01, 01), season: season_2)

        expect(@league.ordered_seasons_by_game_date).to eq([season_2, season_1])
      end

      it 'excludes seasons that dont have games' do
        season_2, season_3 = create_list(:season, 2, league: @league)
        create(:game, date: Date.new(2015, 01, 01), season: season_2)
        create(:game, date: Date.new(2013, 01, 01), season: season_3)

        expect(@league.ordered_seasons_by_game_date).to eq([season_3, season_2])
      end
    end

    context '#participants_count' do
      it 'returns 0 for no participants' do
        expect(@league.participants_count).to eq(0)
      end

      it 'returns 1 for one participant on two players' do
        game1 = create(:game, season: @league.active_season)
        game2 = create(:game, season: @league.active_season)
        participant = create(:participant)
        create(:player, participant: participant, game: game2)
        create(:player, participant: participant, game: game1)

        expect(@league.participants_count).to eq(1)
      end

      it 'returns 2 for two participants on five players' do
        participants = create_list(:participant, 2)
        games = create_list(:game, 5, season: @league.active_season)
        games.each_with_index do |game, index|
          create(:player, participant: participants[index % 2], game: game)
        end

        expect(@league.participants_count).to eq(2)
      end
    end

    context '#seasons_count' do
      it 'returns 1 for one season' do
        expect(@league.seasons_count).to eq(1)
      end

      it 'returns 2 for two seasons' do
        create(:season, league: @league)
        Season.update_all(active: true)

        expect(@league.seasons_count).to eq(2)
      end
    end

    context '#scheduled_games_count' do
      it 'returns 0 for no games scheduled' do
        create_list(:game, 2, completed: true, season: @league.active_season)

        expect(@league.scheduled_games_count).to eq(0)
      end

      it 'returns 1 for one game scheduled' do
        create_list(:game, 5, completed: true, season: @league.active_season)
        create(:game, completed: false, season: @league.active_season)

        expect(@league.scheduled_games_count).to eq(1)
      end

      it 'returns 2 for two games scheduled' do
        create_list(:game, 50, completed: true, season: @league.active_season)
        create(:game, completed: false, season: @league.active_season)
        create(:game, completed: false, season: @league.active_season)

        expect(@league.scheduled_games_count).to eq(2)
      end
    end

    context '#to_param' do
      it 'returns the slug' do
        league2 = create(:league, name: 'testing-123')
        expect(league2.to_param).to eq('testing-123')
      end
    end

    context '#private-create_initial_season' do
      it 'creates an initial season with the league' do
        expect(@league.seasons.count).to eq(1)
      end
    end
  end
end

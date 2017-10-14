require 'rails_helper'

describe Participant, type: :model do
  context 'validations' do
    it { should validate_presence_of :first_name }
    it { should validate_presence_of :last_name }
    it { should validate_presence_of :user_id }
  end

  context 'relationships' do
    it { should belong_to :user }
    it { should have_many :players }
  end

  context 'methods' do
    before do
      @participant = create(:participant)
      @league = create(:league)
    end

    context '#attendance_percentage' do
      it 'returns 0 for no games attended' do
        create_list(:game, 3, season: @league.active_season)
        expect(@participant.attendance_percentage(@league)).to eq(0)
      end

      it 'returns 25.0 for one third games attended' do
        games = create_list(:game, 4, season: @league.active_season)
        create(:player, game: games[0], participant: @participant)
        expect(@participant.attendance_percentage(@league)).to eq(25.0)
      end
    end

    context '#finishing_place_in_game' do
      before do
        @game = create(:game, season: @league.active_season)
      end
      it 'returns the finishing place of the participant' do
        create(:player, participant: @participant, game: @game, finishing_place: 35)
        expect(@participant.finishing_place_in_game(@game)).to eq(35)
      end

      it 'returns nil if the participant did not play in that game' do
        expect(@participant.finishing_place_in_game(@game)).to be nil
      end
    end

    context '#full_name' do
      it 'returns the players full name' do
        @participant.update(first_name: 'Mark', last_name: 'Miranda')
        expect(@participant.full_name).to eq('Mark Miranda')
      end
    end

    context '#games_by_season & #games_count' do
      it 'returns the participants games' do
        season_1 = @league.active_season
        games = create_list(:game, 5, season: season_1)
        season_2 = create(:season, league: @league)
        other_games = create_list(:game, 6, season: season_2)

        games.each { |g| create(:player, game: g, participant: @participant) }
        other_games.each { |g| create(:player, game: g, participant: @participant) }

        expect(@participant.games_by_season(season_1)).to eq(games)
        expect(@participant.games_by_season(season_2)).to eq(other_games)

        expect(@participant.games_count).to eq(11)
      end

      it 'returns an empty array when the participant has no games' do
        expect(@participant.games_by_season(@league.active_season)).to eq([])
        expect(@participant.games_count).to eq(0)
      end
    end

    context '#nemesis' do
      before do
        @participant_2 = create(:participant)
        @game = create(:game, season: @league.active_season)
        create(:player, finishing_place: 1, participant: @participant, game: @game)
        create(:player, finishing_place: 2, participant: @participant_2, game: @game)
      end

      it 'returns the second place participant when called on the first place participant' do
        expect(@participant.nemesis(@game)).to eq(@participant_2)
      end

      it 'returns the first place participant when called on the second place participant' do
        expect(@participant_2.nemesis(@game)).to eq(@participant)
      end

      it 'returns nil when called on the any other participant' do
        participant_3 = create(:participant)
        create(:player, finishing_place: 3, participant: participant_3, game: @game)
        expect(participant_3.nemesis(@game)).to be nil
      end
    end

    context '#ordinal_by_season' do
      before do
        @game = create(:game, season: @league.active_season)
        create(:player, game: @game, participant: @participant, finishing_place: 1)
      end

      it 'returns 1st for first place' do
        @game.calculate_scores
        expect(@participant.ordinal_by_season(@league.active_season)).to eq('1st')
      end

      it 'returns 2nd for second place' do
        participant_2 = create(:participant)
        create(:player, game: @game, participant: participant_2, finishing_place: 9)
        @game.calculate_scores
        expect(participant_2.ordinal_by_season(@league.active_season)).to eq('2nd')
      end
    end

    context '#overall_place_percentage' do
      it 'returns 0 for no second or third place finishes' do
        expect(@participant.overall_place_percentage).to eq(0)
      end

      it 'returns 25.0 for one out of four second or third place finishes' do
        create_list(:game, 4).each_with_index do |game, index|
          create(:player, game: game, participant: @participant, finishing_place: index + 3)
        end
        expect(@participant.overall_place_percentage).to eq(25.0)
      end

      it 'returns 100 for three out of three second or third place finishes' do
        create_list(:game, 4).each do |game|
          create(:player, game: game, participant: @participant, finishing_place: 2)
        end

        expect(@participant.overall_place_percentage).to eq(100.0)
      end
    end

    context '#overall_win_percentage' do
      it 'returns 0 for no wins' do
        expect(@participant.overall_win_percentage).to eq(0)
      end

      it 'returns 25.0 for one out of four wins' do
        game = create(:game)
        create(:player, game: game, participant: @participant, finishing_place: 1)

        create_list(:game, 3).each do |g|
          create(:player, game: g, participant: @participant, finishing_place: 2)
        end

        expect(@participant.overall_win_percentage).to eq(25.0)
      end

      it 'returns 100.0 for ten out of ten wins' do
        create_list(:game, 10).each do |g|
          create(:player, game: g, participant: @participant, finishing_place: 1)
        end

        expect(@participant.overall_win_percentage).to eq(100)
      end
    end

    context '#place_finishes_by_season & #place_finishes_overall' do
      before do
        games = create_list(:game, 2, season: @league.active_season)
        create(:player, game: games[0], finishing_place: 2, participant: @participant)
        create(:player, game: games[1], finishing_place: 2, participant: @participant)

        @participant_2 = create(:participant)
        create(:player, game: games[0], finishing_place: 3, participant: @participant_2)
      end

      it 'returns 0 for no finishes in a specific place' do
        expect(@participant.place_finishes_by_season(@league.active_season, 1)).to eq(0)
      end

      it 'returns 1 for one finishe in a specific place' do
        expect(@participant_2.place_finishes_by_season(@league.active_season, 3)).to eq(1)
      end

      it 'returns 2 for two finishes in a specific place' do
        expect(@participant.place_finishes_by_season(@league.active_season, 2)).to eq(2)
      end

      it 'returns 3 for place finishes overall' do
        new_season = create(:season, league: @league)
        game = create(:game, season: new_season)
        create(:player, game: game, finishing_place: 2, participant: @participant)

        expect(@participant.place_finishes_overall(2)).to eq(3)
      end
    end

    context '#played_in_by_season & #played_in_by_season_percentage' do
      it 'returns 0 for no games played' do
        expect(@participant.played_in_by_season(@league.active_season)).to eq(0)
        expect(@participant.played_in_by_season_percentage(@league.active_season)).to eq(0)
      end

      it 'returns 2 - 50% for two out of 4 games played' do
        games = create_list(:game, 4, season: @league.active_season)
        [games[0], games[3]].each do |game|
          create(:player, game: game, participant: @participant)
        end

        expect(@participant.played_in_by_season(@league.active_season)).to eq(2)
        expect(@participant.played_in_by_season_percentage(@league.active_season)).to eq(50.0)
      end

      it 'returns 10 - 100% for all games played' do
        create_list(:game, 10, season: @league.active_season).each do |game|
          create(:player, game: game, participant: @participant)
        end

        expect(@participant.played_in_by_season(@league.active_season)).to eq(10)
        expect(@participant.played_in_by_season_percentage(@league.active_season)).to eq(100.0)
      end
    end

    context '#player_since' do
      it 'returns nil without a game' do
        expect(@participant.player_since).to be nil
      end

      it 'returns the date and month for a player with a game' do
        create(:game, date: Date.new(1999, 1, 1)) do |game|
          create(:player, game: game, participant: @participant)
        end

        expect(@participant.player_since).to eq('January 1999')
      end
    end

    context 'reversed_games_by_season' do
      it 'returns an empty array for no games' do
        expect(@participant.reversed_games_by_season(@league.active_season)).to eq([])
      end

      it 'returns the games in reverse order' do
        games = create_list(:game, 5, season: @league.active_season)
        games.each do |game|
          create(:player, game: game, participant: @participant)
        end

        expect(@participant.reversed_games_by_season(@league.active_season)).to eq(games.reverse)
      end
    end

    context '#reversed_seasons' do
      it 'returns a nil if there are no games' do
        expect(@participant.reversed_seasons).to be nil
      end

      it 'returns a single season for 1 game' do
        create(:game, season: @league.active_season) do |game|
          create(:player, game: game, participant: @participant)
        end

        expect(@participant.reversed_seasons).to eq([@league.active_season])
      end

      it 'returns seasons reversed for 2 seasons' do
        create(:game, season: @league.active_season) do |game|
          create(:player, game: game, participant: @participant)
        end

        create(:season, league: @league) do |season|
          create(:game, season: season) do |game|
            create(:player, game: game, participant: @participant)
          end
        end

        expect(@participant.reversed_seasons).to eq([Season.last, Season.first])
      end
    end

    context '#score_by_game & #season_score' do
      it 'returns the score' do
        game = create(:game, season: @league.active_season)
        create(:player, game: game, participant: @participant, finishing_place: 1)
        game.calculate_scores

        expect(@participant.score_by_game(game)).to eq(3.53)
        expect(@participant.season_score(@league.active_season)).to eq(3.53)
      end
    end

    context '#season_place_percentage & #season_win_percentage' do
      it 'returns 0 for no wins or places' do
        expect(@participant.season_place_percentage(@league.active_season)).to eq(0)
        expect(@participant.season_win_percentage(@league.active_season)).to eq(0)
      end

      it 'returns 50% for both for one out of two' do
        create_list(:game, 2, season: @league.active_season).each_with_index do |game, index|
          create(:player, game: game, participant: @participant, finishing_place: index + 1)
        end
        expect(@participant.season_place_percentage(@league.active_season)).to eq(50.0)
        expect(@participant.season_win_percentage(@league.active_season)).to eq(50.0)
      end
    end

    context 'self#ordered_by_total_score_by_season' do
      it 'returns an empty array for no games in a season' do
        expect(Participant.ordered_by_total_score_by_season(@league.active_season.id)).to eq([])
      end

      it 'returns sorted participants by score in a given season' do
        part_2 = create(:participant)
        game = create(:game, season: @league.active_season)
        [@participant, part_2].each_with_index do |participant, index|
          create(:player, finishing_place: index + 1, game: game, participant: participant)
        end
        game.calculate_scores
        expect(Participant.ordered_by_total_score_by_season(@league.active_season)).to eq([@participant, part_2])
      end
    end

    context '#won_or_placed_in_by_season & #won_or_placed_in_by_season_percentage' do
      it 'returns 0 for no games won or placed in' do
        games = create_list(:game, 4, season: @league.active_season)
        games.each do |game|
          create(:player, participant: @participant, game: game, finishing_place: 4)
        end

        expect(@participant.won_or_placed_in_by_season_percentage(@league.active_season)).to eq(0)
        expect(@participant.won_or_placed_in_by_season(@league.active_season)).to eq(0)
      end

      it 'returns 75% or 3 for three quarters games won or placed in' do
        games = create_list(:game, 4, season: @league.active_season)
        games.each_with_index do |game, index|
          create(:player, participant: @participant, game: game, finishing_place: index + 1)
        end

        expect(@participant.won_or_placed_in_by_season(@league.active_season)).to eq(3)
        expect(@participant.won_or_placed_in_by_season_percentage(@league.active_season)).to eq(75.0)
      end
    end
  end
end

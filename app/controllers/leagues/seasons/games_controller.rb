class Leagues::Seasons::GamesController < ApplicationController
  before_action :load_league
  before_action :load_season
  before_action :load_game, only: [:show, :edit, :update]
  before_action :load_league_and_season_breadcrumbs

  def index
    add_breadcrumb 'Games', league_season_games_path(@league, @season)
    @games = @season.games
  end

  def show
    add_breadcrumb "Game ##{@game.number_by_season}", league_season_game_path(@league, @season, @game)
  end

  def new
    @game = @season.games.new
  end

  def create
    @game = @season.games.create(game_params)
    if @game.save
      redirect_to league_season_game_path(league_slug: @season.league.slug, season_id: @season.id, id: @game.id)
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @game.update(game_params)
      redirect_to league_season_game_path(league_slug: @season.league.slug, season_id: @season.id, id: @game.id)
    else
      render :new
    end
  end

  private

  def load_league_and_season_breadcrumbs
    add_breadcrumb @league.name, league_path(@league)
    add_breadcrumb "Season ##{@season.number_by_league(@league)}", league_season_path(@league, @season)
  end

  def load_game
    @game = Game.find(params[:id])
  end

  def load_season
    @season = Season.find(params[:season_id])
  end

  def load_league
    @league = League.find_by_slug(params[:league_slug])
  end

  def game_params
    params.require(:game).permit(:attendees, :buy_in, :completed, :date)
  end
end

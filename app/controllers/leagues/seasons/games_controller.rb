class Leagues::Seasons::GamesController < ApplicationController
  before_action :load_league, only: [:show]
  before_action :load_season, only: [:index, :show, :new, :create, :update]
  before_action :load_game, only: [:show, :edit, :update]

  def index
    @games = @season.games
  end

  def show
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

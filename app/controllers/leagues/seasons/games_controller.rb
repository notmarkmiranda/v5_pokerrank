class Leagues::Seasons::GamesController < ApplicationController
  before_action :load_season, only: [:create, :update]
  before_action :load_game, only: [:show, :edit, :update]

  def show
  end

  def new
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

  def game_params
    params.require(:game).permit(:attendees, :buy_in, :completed, :date)
  end
end

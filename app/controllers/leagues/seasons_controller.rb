class Leagues::SeasonsController < ApplicationController
  before_action :load_league, only: [:index, :new, :create, :show, :edit, :update]
  before_action :load_season, only: [:show, :edit, :update]
  before_action :verify_league_ownership, only: [:new]
  before_action :verify_season_ownership, only: [:show]

  def index
    @seasons = @league.seasons.reverse_order
  end

  def show
  end

  def new
  end

  def create
    @season = @league.seasons.new(season_params)
    if @season.save
      redirect_to league_season_path(league_slug: @league.slug, id: @season.id)
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @season.update(season_params)
      redirect_to league_season_path(league_slug: @league.slug, id: @season.id)
    else
    end
  end
  private

  def load_league
    @league = League.find_by(slug: params[:league_slug])
  end

  def load_season
    @season = Season.find(params[:id])
  end

  def season_params
    params.require(:season).permit(:active)
  end

  def verify_league_ownership
    redirect_to root_path unless current_user && (@league.user_id == current_user.id)
  end

  def verify_season_ownership
    redirect_to root_path unless @season.league == @league
  end
end

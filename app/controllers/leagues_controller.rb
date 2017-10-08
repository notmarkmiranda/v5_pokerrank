class LeaguesController < ApplicationController
  before_action :require_user, except: [:show]
  before_action :load_league, only: [:show, :edit, :update]
  before_action :verify_ownership, only: [:edit, :update]

  def show
    add_breadcrumb @league.name, league_path(@league)
    @active_season = @league.active_season
    @season_leader = @active_season.season_leader
    @biggest_game  = @active_season.biggest_game
  end

  def new
    @league = League.new
  end

  def create
    @league = current_user.leagues.new(league_params)
    if @league.save
      redirect_to @league
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @league.update(league_params)
      redirect_to @league
    else
      render :edit
    end
  end

  private

  def league_params
    params.require(:league).permit(:name, :slug)
  end

  def load_league
    @league = League.find_by(slug: params[:slug])
    redirect_to root_path if @league.nil?
  end

  def verify_ownership
    redirect_to root_path unless current_user.id == @league.user_id
  end
end

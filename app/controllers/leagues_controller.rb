class LeaguesController < ApplicationController
  before_action :require_user, except: [:show]
  before_action :load_league, only: [:show, :edit, :update]
  before_action :verify_ownership, only: [:edit, :update]

  def show
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
  end

  def verify_ownership
    redirect_to root_path unless current_user.id == @league.user_id
  end
end

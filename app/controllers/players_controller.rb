class PlayersController < ApplicationController
  before_action :require_user
  before_action :load_and_verify_ownership, only: [:show, :edit, :update]

  def show
  end

  def new
  end

  def create
    @player = Player.new(player_params)
    if @player.save
      redirect_to @player
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @player.update(player_params)
      redirect_to @player
    else
      render :edit
    end
  end

  private

  def load_and_verify_ownership
    @player = Player.find(params[:id])
    redirect_to root_path unless @player.user.id == current_user.id
  end

  def player_params
    params.require(:player).permit(:participant_id, :finishing_place, :game_id, :additional_expense, :score)
  end
end

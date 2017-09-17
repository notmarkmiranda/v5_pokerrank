class Leagues::Seasons::Games::PlayersController < ApplicationController
  def create
    set_redirect
    @game = Game.find(params[:game_id])
    @player = @game.players.new(player_params)
    if @game.save
      redirect_to session[:redirect]
    else
      redirect_to session[:redirect]
    end
  end

  private

  def player_params
    params.require(:player).permit(:participant_id, :finishing_place, :additional_expense)
  end
end

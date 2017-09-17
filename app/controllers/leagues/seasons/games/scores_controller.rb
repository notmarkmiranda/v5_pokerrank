class Leagues::Seasons::Games::ScoresController < ApplicationController
  def show
    @game = Game.find(params[:game_id])
    @player = Player.new
  end
end


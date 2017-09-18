class Leagues::Seasons::PlayersController < ApplicationController
  def index
    @season = Season.find(params[:season_id])
    @participants = Participant.ordered_by_total_score_by_season(params[:season_id])
  end
end

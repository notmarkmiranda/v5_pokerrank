class Leagues::ParticipantsController < ApplicationController
  before_action :load_league, only: [:show]

  def show
    @participant = Participant.find(params[:id])
    @seasons = @participant.reversed_seasons
  end

  private

  def load_league
    @league = League.find_by_slug(params[:league_slug])
  end
end

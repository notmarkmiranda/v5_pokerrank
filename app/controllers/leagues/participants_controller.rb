class Leagues::ParticipantsController < ApplicationController

  def show
    add_breadcrumb league.name, league_path(league)
    add_breadcrumb 'Players', session[:redirect], if: :came_from_somehwere?
    add_breadcrumb participant.full_name, league_participant_path(league)
    @seasons = @participant.reversed_seasons
  end

  private

  def league
    @league = League.find_by_slug(params[:league_slug])
  end

  def participant
    @participant = Participant.find(params[:id])
  end
end


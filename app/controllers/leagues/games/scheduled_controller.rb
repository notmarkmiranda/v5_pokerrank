class Leagues::Games::ScheduledController < ApplicationController
  before_action :require_user
  before_action :load_and_verify_league

  def index
    @games = @league.games.where(completed: false)
  end

  private

  def load_and_verify_league
    @league = League.find_by(slug: params[:league_slug])
  end
end

class Leagues::Seasons::PlayersController < ApplicationController

  def index
    add_breadcrumb league.name, league_path(league)
    add_breadcrumb "Season #{season.number_by_league(league)}", league_season_path(league, season)
    add_breadcrumb "Players", league_season_players_path(league, season)
    @season = Season.find(params[:season_id])
    @participants = Participant.ordered_by_total_score_by_season(params[:season_id])
  end

  private

  def league
    @league = League.find_by_slug(params[:league_slug])
  end

  def season
    @season = Season.find(params[:season_id])
  end

end

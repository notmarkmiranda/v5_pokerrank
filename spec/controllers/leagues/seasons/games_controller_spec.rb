require 'rails_helper'

describe Leagues::Seasons::GamesController, type: :controller do
  context 'create a new game flow' do
    before do
      @season = create(:season)
      @league = @season.league
      user = @league.user
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
    end

    it 'GET#new' do
      get :new, params: { league_slug: @league.slug, season_id: @season.id }
      expect(response).to render_template :new
    end

    it 'POST#create - happy path' do
      attrs = attributes_for(:game, season: @season)
      post :create, params: { league_slug: @league.slug, season_id: @season.id, game: attrs }
      expect(response).to redirect_to league_season_game_path(league_slug: @league.slug, season_id: @season.id, id: Game.last.id)
    end

    it 'POST#create - sad path' do
      attrs = attributes_for(:game, season: @season)
      post :create, params: { league_slug: @league.slug, season_id: @season.id, game: attrs.except(:buy_in) }
      expect(response).to render_template :new
    end

    it 'GET#show' do
      game = create(:game, season: @season)
      get :show, params: { league_slug: @league.slug, season_id: @season.id, id: game.id }
      expect(response).to render_template :show
    end
  end

  context 'edit an existing game flow' do
    before do
      @game = create(:game)
      @season = @game.season
      @league = @season.league
      user = @league.user
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
    end

    it 'GET#edit' do
      get :edit, params: { league_slug: @league.slug, season_id: @season.id, id: @game.id }
      expect(response).to render_template :edit
    end

    it 'PATCH#update - happy path' do
      attrs = { buy_in: 300 }
      patch :update, params: { league_slug: @league.slug, season_id: @season.id, id: @game.id, game: attrs }
      expect(response).to redirect_to league_season_game_path(league_slug: @league.slug, season_id: @season.id, id: @game.id)
    end

    it 'PATCH#update - sad path' do
      attrs = { buy_in: '' }
      patch :update, params: { league_slug: @league.slug, season_id: @season.id, id: @game.id, game: attrs }
      expect(response).to render_template :new
    end
  end

  context 'deactivate game flow' do
    it 'deactivates a game'
  end
end

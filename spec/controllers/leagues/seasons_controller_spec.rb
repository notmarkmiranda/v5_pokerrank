require 'rails_helper'

describe Leagues::SeasonsController, type: :controller do
  context 'create a new season flow' do
    before do
      @league = create(:league)
      user = @league.user
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
    end

    it 'GET#new' do
      get :new, params: { league_slug: @league.slug }
      expect(response).to render_template :new
    end

    it 'POST#create' do
      attrs = attributes_for(:season, league: @league)
      post :create, params: { league_slug: @league.slug, season: attrs }
      expect(response).to redirect_to league_season_path(@league.slug, Season.last)
    end

    it 'POST#create - happy path with other seasons active' do
      create(:season, league: @league)
      attrs = attributes_for(:season)
      post :create, params: { league_slug: @league.slug, season: attrs }
      expect(Season.count).to eq(3)
      expect(Season.last.active).to be true
      expect(Season.first.active).to be false
    end

    it 'POST#create - happy path with other seasons not active' do
      create(:season, league: @league)
      Season.update_all(active: false)
      attrs = attributes_for(:season)
      post :create, params: { league_slug: @league.slug, season: attrs }

      expect(Season.pluck(:active)).to eq([true, false, false])
    end

    it 'GET#show' do
      season = create(:season, league: @league)
      get :show, params: { league_slug: @league.slug, id: season.id }
      expect(response).to render_template :show
    end
  end

  context 'update an existing season' do
    before do
      @league = create(:league)
      @season = @league.seasons.first
      user = @league.user
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
    end

    it 'GET#edit' do
      get :edit, params: { league_slug: @league.slug, id: @season.id }
      expect(response).to render_template :edit
    end

    it 'PATCH#update - happy path' do
      patch :update, params: { league_slug: @league.slug, id: @season.id, season: { active: false } }
      expect(response).to redirect_to league_season_path(league_slug: @league.slug, id: @season.id)
    end

    it 'PATCH#update - with other seasons active' do
      other_season = create(:season, league: @league, active: false)
      patch :update, params: { league_slug: @league.slug, id: other_season.id, season: { active: true } }
      expect(@season.reload.active).to be false
    end
  end
end

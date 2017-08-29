require 'rails_helper'

describe LeaguesController, type: :controller do
  context 'create league - logged in user' do
    before do
      @user = create(:user)
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user)
    end

    it 'GET#new' do
      get :new
      expect(response).to render_template :new
    end

    it 'POST#create - happy path' do
      attrs = attributes_for(:league, user: @user)
      post :create, params: { league: attrs.except(:slug) }
      expect(response).to redirect_to League.last
    end

    it 'POST#create - sad path' do
      attrs = attributes_for(:league, user: @user)
      post :create, params: { league: attrs.except(:name) }
      expect(response).to render_template :new
    end

    it 'GET#show' do
      league = create(:league, user: @user)
      get :show, params: { slug: league.slug }
      expect(response).to render_template :show
    end
  end

  context 'edit league' do
    before do
      @user = create(:user)
      @league = create(:league, user: @user)
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user)
    end

    it 'GET#edit - owner' do
      get :edit, params: { slug: @league.slug }
      expect(response).to render_template :edit
    end

    it 'GET#edit - non-owner' do
      league2 = create(:league)
      get :edit, params: { slug: league2.slug }
      expect(response).to redirect_to root_path
    end

    it 'PATCH#update - happy path' do
      patch :update, params: { slug: @league.slug, league: { name: 'testing-123' } }
      expect(response).to redirect_to @league.reload
    end

    it 'PATCH#update - sad path' do
      patch :update, params: { slug: @league.slug, league: { name: '' } }
      expect(response).to render_template :edit
    end
  end

  context 'deactivate league' do
    xit 'GET#destroy'
  end
end

require 'rails_helper'

describe SessionsController, type: :controller do
  context do
    it 'GET#new' do
      get :new
      expect(response).to render_template :new
    end

    it 'GET#new - redirect signed in user' do
      user = create(:user)
      get :new, session: { user_id: user.id }
      expect(response).to redirect_to not_found_path
    end

    it 'POST#create - happy path' do
      user = create(:user)
      post :create, params: { session: { email: user.email, password: 'password' } }, session: { redirect: dashboard_path }
      expect(response).to redirect_to dashboard_path
    end

    it 'POST#create - sad path' do
      user = create(:user)
      post :create, params: { session: { email: user.email, password: 'asdf' } }
      expect(response).to render_template :new
    end

    it 'GET#destroy' do
      user = create(:user)
      get :destroy, params: { session: { user_id: user.id } }
      expect(response).to redirect_to root_path
    end
  end
end

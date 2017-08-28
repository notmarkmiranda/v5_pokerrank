require 'rails_helper'

describe UsersController, type: :controller do
  context 'sign up flow' do
    it 'GET#new' do
      get :new
      expect(response).to render_template :new
    end

    it 'GET#new - sad path, user signed in' do
      user = create(:user)
      get :new, session: { user_id: user.id }
      expect(response).to redirect_to not_found_path
    end

    it 'POST#create' do
      attrs = attributes_for(:user)
      expect {
        post :create, params: { user: attrs }
      }.to change(User, :count)
      expect(response).to redirect_to dashboard_path
    end

    it 'GET#show' do
      user = create(:user)
      get :show, session: { user_id: user.id }
      expect(response).to render_template :show
    end
  end

  context 'edit profile flow' do
    before do
      @user = create(:user)
    end

    it 'GET#edit' do
      get :edit, session: { user_id: @user.id }
      expect(response).to render_template :edit
    end

    it 'PATCH#update' do
      patch :update, params: { id: @user.id, user: { email: 'a@b.com' } }, session: { user_id: @user.id }
      expect(response).to redirect_to dashboard_path
    end
  end

  context 'deactivate profile' do
    # Later Iteration
    xit 'GET#destroy'
  end
end

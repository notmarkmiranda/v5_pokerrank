require 'rails_helper'

describe ParticipantsController, type: :controller do
  context 'create a new participant flow' do
    before do
      user = create(:user)
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
    end

    it 'GET#new' do
      get :new
      expect(response).to render_template :new
    end

    it 'POST#create - happy path' do
      attrs = attributes_for(:participant)
      post :create, params: { participant: attrs }
      expect(response).to redirect_to Participant.last
    end

    it 'POST#create - sad path' do
      attrs = attributes_for(:participant)
      post :create, params: { participant: attrs.except(:first_name) }
      expect(response).to render_template :new
    end

    it 'GET#show' do
      participant = create(:participant)
      get :show, params: { id: participant.id }
      expect(response).to render_template :show
    end
  end

  context 'edit an existing participant flow' do
    before do
      user = create(:user)
      @participant = create(:participant, user: user)
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
    end

    it 'GET#edit' do
      get :edit, params: { id: @participant.id }
      expect(response).to render_template :edit
    end

    it 'PATCH#update - happy path' do
      patch :update, params: { id: @participant.id, participant: { first_name: 'mark!' } }
      expect(response).to redirect_to @participant
    end

    it 'PATCH#update - sad path' do
      patch :update, params: { id: @participant.id, participant: { first_name: '' } }
      expect(response).to render_template :edit
    end
  end

  context 'deactivate a participant flow'
end

require 'rails_helper'

describe PlayersController, type: :controller do
  context 'create a player flow' do
    before do
      @user = create(:user)
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user)
    end

    it 'GET#new' do
      get :new
      expect(response).to render_template :new
    end

    it 'POST#create - happy' do
      game = create(:game)
      participant = create(:participant)
      attrs = attributes_for(:player, game_id: game.id, participant_id: participant.id)
      post :create, params: { player: attrs }
      expect(response).to redirect_to Player.last
    end

    it 'POST#create - sad' do
      game = create(:game)
      participant = create(:participant)
      attrs = attributes_for(:player, game_id: game.id, participant_id: participant.id)
      post :create, params: { player: attrs.except(:game_id) }
      expect(response).to render_template :new
    end

    it 'GET#show' do
      participant = create(:participant, user: @user)
      player = create(:player, participant: participant)
      get :show, params: { id: player.id }
      expect(response).to render_template :show
    end
  end

  context 'edit a player flow' do
    before do
      @player = create(:player)
      user = @player.participant.user
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
    end

    it 'GET#edit' do
      get :edit, params: { id: @player.id }
      expect(response).to render_template :edit
    end

    it 'PATCH#update - happy' do
      patch :update, params: { id: @player.id, player: { finishing_place: 3 } }
      expect(response).to redirect_to @player
    end

    it 'PATCH#update - sad' do
      patch :update, params: { id: @player.id, player: { game_id: '' } }
      expect(response).to render_template :edit
    end
  end
end

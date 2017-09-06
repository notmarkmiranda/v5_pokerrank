require 'rails_helper'

describe Leagues::Games::ScheduledController, type: :controller do
  before do
    @league = create(:league)
    user = @league.user
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
  end

  it 'GET#index' do
    get :index, params: { league_slug: @league.slug }
    expect(response).to render_template :index
  end
end

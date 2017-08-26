require 'rails_helper'

describe Season, type: :model do
  context 'validations' do
    it { should validate_presence_of :league_id }
  end

  context 'relationships' do
    it { should belong_to :league }
  end

  context 'methods' do
    before do
      @league = create(:league)
      @season = @league.seasons.first
    end

    it 'only one active season - create' do
      @league.seasons.create

      expect(@season.reload.active).to eq(false)
    end

    it 'only one active season - update' do
      @league.seasons.create
      @league.seasons.create
      season = Season.where(active: false).last
      season.update(active: true)

      expect(Season.where(active:false).include?(season)).to be false
    end
  end
end

require 'rails_helper'

describe League, type: :model do
  context 'validations' do
    it { should validate_presence_of :name }
    it { should validate_uniqueness_of :name }
    it { should validate_presence_of :slug }
    it { should validate_presence_of :user_id }
  end

  context 'relationships' do
    it { should belong_to :user }
    it { should have_many :seasons }
    it { should have_many(:games).through(:seasons) }
    it { should have_many(:players).through(:games) }
  end

  context 'methods' do
    it 'creates an initial season with the league' do
      league = create(:league)
      expect(league.seasons.count).to eq(1)
    end
  end
end

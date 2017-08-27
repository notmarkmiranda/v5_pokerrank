require 'rails_helper'

describe User, type: :model do
  context 'validations' do
    it { should validate_presence_of :email }
    it { should validate_uniqueness_of :email }
  end

  context 'relationships' do
    it { should have_many :leagues }
    it { should have_many :participants }
  end
end

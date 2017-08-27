require 'rails_helper'

describe Participant, type: :model do
  context 'validations' do
    it { should validate_presence_of :first_name }
    it { should validate_presence_of :last_name }
    it { should validate_presence_of :user_id }
  end

  context 'relationships' do
    it { should belong_to :user }
  end
end

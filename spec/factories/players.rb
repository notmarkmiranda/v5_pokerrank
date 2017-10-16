FactoryGirl.define do
  factory :player do
    participant
    sequence :finishing_place { |n| n + 1 }
    game
    additional_expense 100
  end
end

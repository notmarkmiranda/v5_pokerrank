FactoryGirl.define do
  factory :player do
    participant
    sequence :finishing_place { |n| n + 1 }
    game
    sequence :additional_expense { |n| 100 + n }
  end
end

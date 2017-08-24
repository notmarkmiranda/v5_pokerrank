FactoryGirl.define do
  factory :league do
    sequence :name { |n| "league #{n}" }
    user
    sequence :slug { |n| "league-#{n}" }
  end
end

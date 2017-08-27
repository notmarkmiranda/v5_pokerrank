FactoryGirl.define do
  factory :participant do
    sequence :first_name { |n| "first_name_#{n}" }
    sequence :last_name { |n| "last_name_#{n}" }
    user
  end
end

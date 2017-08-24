FactoryGirl.define do
  factory :user do
    sequence :email { |n| "test_email_#{n}@example.com" }
    password 'password'
    password_confirmation 'password'
  end
end

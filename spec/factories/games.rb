FactoryGirl.define do
  factory :game do
    date Date.new(2015, 5, 9)
    buy_in 100
    completed false
    season
    attendees 10
  end
end

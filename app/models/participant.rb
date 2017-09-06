class Participant < ApplicationRecord
  validates_presence_of :first_name
  validates_presence_of :last_name
  validates_presence_of :user_id

  belongs_to :user

  def full_name
    "#{first_name.titleize} #{last_name.titleize}"
  end
end

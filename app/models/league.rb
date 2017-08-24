class League < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  validates_presence_of :slug
  validates_presence_of :user_id

  belongs_to :user
  before_validation :set_slug

  private

  def set_slug
    self.slug ||= name.parameterize if name
  end
end

class League < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  validates_presence_of :slug
  validates_presence_of :user_id

  belongs_to :user
  has_many :seasons
  has_many :games, through: :seasons

  before_validation :set_slug
  after_create_commit :create_initial_season

  private

  def create_initial_season
    seasons.create(active: true)
  end

  def set_slug
    self.slug ||= name.parameterize if name
  end
end
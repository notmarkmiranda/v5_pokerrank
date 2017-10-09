class League < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  validates_presence_of :slug
  validates_presence_of :user_id

  belongs_to :user
  has_many :seasons
  has_many :games, through: :seasons
  has_many :players, through: :games

  before_validation :set_slug
  after_create_commit :create_initial_season

  def active_season
    seasons.where(active: true).last
  end

  def completed_games_count
    games.where(completed: true).count
  end

  def has_uncompleted_game?
    games.any? { |game| game.completed == false }
  end

  def has_active_season?
    seasons.any? { |season| season.active == true }
  end

  def games_count
    games.count
  end

  def ordered_seasons_by_game_date
    filtered_seasons_with_games.sort_by do |season|
      next if season.games.empty?
      season.games.first.date
    end
  end

  def participants_count
    players.pluck(:participant_id).uniq.count
  end

  def seasons_count
    seasons.count
  end

  def scheduled_games_count
    games.where(completed: false).count
  end

  def to_param
    self.slug if slug
  end

  private

  def create_initial_season
    seasons.create(active: true)
  end

  def filtered_seasons_with_games
    seasons.select { |season| season.games.any? }
  end

  def set_slug
    self.slug = name.parameterize if name
  end
end

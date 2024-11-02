class Game  < ActiveRecord::Base
  include PgSearch

  module GameBadgeableEventTypes
    REWARD = 'reward'
    RESTRICTION = 'restriction'
  end

  module RecommendedGames
    GAME_IDS = [
                46, # Willkommen bei rylyty!
                41, # Streetart mit Lego
                 9, # Frohe Weihnachten
                64, # Kuss-Fotos
                55 # Europa-Pionier
               ]
  end

  belongs_to :author, class_name: 'User'
  belongs_to  :quest
  has_many :tasks, order: 'position', dependent: :destroy
  has_many :user_games, dependent: :destroy
  has_many :mission_games, inverse_of: :game, dependent: :destroy
  has_many :missions, through: :mission_games
  has_many :games_tags
  has_many :categories, through: :games_tags, source: :tag, conditions: { tags: { context: Tag::GAME_CATEGORY_TYPE } }

  has_attached_file :icon, styles: { normal_hi: "98x98>", normal: "49x49>", feed: "90x90>", feed_hi: "180x180>" },
      path: ":rails_root/public/assets/games/:id/:attachment/:filename_:style"

  has_attached_file :image, styles: { normal_hi: "210x640>", normal_5: "386x640>", normal: "105x320>", icon_hi: "98x98>", icon: "49x49>" },
      path: ":rails_root/public/assets/games/:id/:attachment/:filename_:style"

  attr_accessible :costs, :title, :short_description, :description, :suggestion, :minimum_age,
                  :time_limit, :author, :image, :icon, :categories, :missions,
                  :points, :restriction_points,
                  :image_file_name, :image_content_type, :image_file_size, :image_updated_at,
                  :icon_file_name, :icon_content_type, :icon_file_size, :icon_updated_at,
                  :reward_badge_id, :restriction_badge_id

  pg_search_scope :search_full_text,
                  against: [ :title, :short_description, :description ],
                  using: {
                    tsearch: {dictionary: "german", prefix: true}
                  }

  validates :title, presence: true
  validates :short_description, presence: true
  validates :description, presence: true
  validates :costs, presence: true

  def users_count
    user_games.count
  end

  def tasks_count
    tasks.count
  end

  def total_reward_points
    points + tasks.reduce(0) {|n, task| n + task.points}
  end

  # category_name - string
  def add_category category_name
    categories << Tag.find_or_create_by_value_and_context(value: category_name, context: Tag::GAME_CATEGORY_TYPE)
  end

  def reward_badge
    Badge.find(self.reward_badge_id) unless self.reward_badge_id.nil?
  end

  def remove_reward_badge
    update_attributes(reward_badge_id: nil)
  end

  def add_reward_badge badge
    raise "Es wurde bereits ein Belohnungs Badge '#{reward_badge.title}' zugewiesen" if reward_badge.present?
    update_attributes(reward_badge_id: badge.id)
  end

  def add_restriction_badge badge
    update_attributes(restriction_badge_id: badge.id)
  end

  def restriction_badge
    Badge.find(self.restriction_badge_id) unless self.restriction_badge_id.nil?
  end

  def remove_restriction_badge
    self.restriction_badge_id = nil
  end

  def icon_url
    icon.present? ? icon.url(:normal) : image.url(:icon)
  end

  def icon_url_hi
    icon.present? ? icon.url(:normal_hi) : image.url(:icon_hi)
  end

  def self.without_mission
    includes(:mission_games).where( mission_games: { game_id: nil })
  end

  def self.recommended_games
    Game.where(id: RecommendedGames::GAME_IDS)
    .to_a.sort{|g1,g2|(RecommendedGames::GAME_IDS.index(g1.id) >= RecommendedGames::GAME_IDS.index(g2.id)) ? 1 : -1}
  end
end
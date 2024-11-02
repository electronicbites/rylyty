class UserGame < ActiveRecord::Base

  attr_accessible :feed_visibility, :feedable

  module Visibility
    COMMUNITY = 'community'
    FRIENDS = 'friends'
  end

  module EventTypes
    COMPLETED = 'game_completed'
  end

  belongs_to :user
  belongs_to :game
  has_many   :user_tasks, dependent: :destroy, order: 'position'
  has_many :feed_items, as: :feedable

  validate :feed_visibility, :validates_visibility_by_user_age, on: :update

  after_create :set_visibility

  attr_accessible :finished_at

  validates :game_id, uniqueness: {scope: :user_id, message: I18n.t("user_games.already_bought", locale: 'de')}

  state_machine :state, initial: :active do |user_game|
    state :active
    state :canceled
    state :completed

    event :cancel do
      transition :active => :cancel
    end

    event :complete do
      transition :from => :active, :to => :completed, :if => :all_tasks_completed?
    end

    after_transition to: :completed do |user_game, transition|
      user_game.update_attributes(finished_at: DateTime.now)
      user = user_game.user
      user_game.collect_points user_game.game.points
      
      if !user.friend_ids.empty? || user_game.feed_visibility == UserGame::Visibility::COMMUNITY
        Notifications.publish 'write_friend_feed_item',
          reference: user_game.game, sender: user,
          receiver_ids: user.friend_ids ,
          event_type: UserGame::EventTypes::COMPLETED,
          visibility: user_game.feed_visibility,
          feedable: user_game.game
      end
      Notifications.publish 'set_game_completion_badges', for: user_game
    end
  end

  ##
  #
  # @params [Boolean] include_optional Whether to include optional tasks
  #                   (default: `false`, only required tasks will be checked)
  def all_tasks_completed? include_optional = false
    (!open_tasks?(include_optional) && all_tasks_verified?(include_optional))
  end

  ##
  # check if there are any open tasks
  #
  # @params [Boolean] include_optional Whether to include optional tasks
  #                   (default: `false`, only required tasks will be checked)
  def open_tasks? include_optional = false
    opts = {state: :open}
    opts[:optional] = false unless include_optional
    user_tasks.where(opts).count > 0
  end

  ##
  #
  # @params [Boolean] include_optional Whether to include optional tasks
  #                   (default: `false`, only required tasks will be checked)
  def open_tasks include_optional = false
    opts = {state: :open}
    opts[:optional] = false unless include_optional
    user_tasks.where(opts)
  end

  ##
  #
  # @params [Boolean] include_optional Whether to include optional tasks
  #                   (default: `false`, only required tasks will be checked)
  def all_tasks_verified? include_optional = false
    opts = {}
    opts[:optional] = false unless include_optional
    user_tasks.where(opts).all? { |t| t.verification_verified? }
  end

  def task_canceled
    self.cancel
  end

  def task_verified
    self.complete
  end

  #the visiibility is always friends if the user is less than 16 years old
  def validates_visibility_by_user_age

    return unless self.feed_visibility_change

    if self.user.age < 16 && self.feed_visibility == UserGame::Visibility::COMMUNITY
      errors.add(:feed_visibility, 'visibility must set to friends')
    end

  end

  # default is set to community, set to friends if user is less than 16 years old
  def set_visibility
    update_attributes(feed_visibility: UserGame::Visibility::FRIENDS) if self.user.age < 16
  end

  def playable?
    self.user.can_play self.game
  end

  def collect_points points
    self.user.earn_points points
  end
end

class User < ActiveRecord::Base
  include LeapYears

  module EventTypes
    FB_FRIEND_SIGNED_UP = 'facebook_friend_signed_up'
  end

  has_many :authored_games, class_name: 'Game'

  has_many :user_games, dependent: :destroy
  has_many :user_tasks, order: 'position', dependent: :destroy

  has_many :tasks, through: :user_tasks, source: :task
  has_many :games, through: :user_games, source: :game
  has_many :user_missions
  has_many :likes
  has_many :badges, through: :user_badges, source: :badge
  has_many :user_badges

  has_many :friendships
  has_many :inverse_friendships, class_name: "Friendship", foreign_key: "friend_id"
  has_many :friends_by_me, through: :friendships, source: :friend
  has_many :friends_for_me, through: :inverse_friendships, source: :user
  has_many :feed_items, as: :feedable

  has_many :invitations, foreign_key: 'invited_by_id', dependent: :destroy

  has_attached_file :avatar, styles: { thumb_hi: "80x80>", thumb: "40x40>", normal_hi: "184x184>", normal: "92x92>", feed: "90x90>", feed_hi: "180x180>" },
      :path => ":rails_root/public/assets/:attachment/users/:id/:style/:filename"

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable

  scope :with_facebook, where('facebook_id is not null')

  # Setup accessible (or protected) attributes for your model
  attr_accessible :username, :email, :password, :password_confirmation,
                  :remember_me, :birthday, :login, :avatar,
                  :facebook_id, :facebook_profile_url, :credits,
                  :tos,
                  :feedable

  attr_accessor :login

  validates :username, presence: true, uniqueness: true, length: {minimum: 2}, format: {with: /^[\w.-_]+$/}
  validates_attachment :avatar, :size => { :less_than => 2.megabytes }
  validates :facebook_id, format: {with: /^[0-9]+$/}, uniqueness: true, allow_nil: true

  validates :email, format: Devise.email_regexp, presence: true,
                    uniqueness: {case_sensitive: false}
  validates :password, presence: true, confirmation: true, length: {within: Devise.password_length},
                    on: :create, :unless => :facebook_user?
  validates_acceptance_of :tos, on: :create, accept: 'true', allow_nil: false
  validates :credits, presence: true, allow_nil: false

  def buy_game! game
    return false unless can_buy game
    user_game = add_game game
    self.credits = (self.credits || 0) - game.costs
    save
    user_game
  end

  def earn_points points
    self.user_points += points
    self.save!
  end

  ##
  # Create a beta invite
  def beta_invite email, invited_to=nil
    return false unless beta_invitations_issued < beta_invitations_budget
    Invitation.create email: email, invited_by: self, invited_to: invited_to
    self.beta_invitations_issued += 1
    save
  end

  def invite user, invited_to
    Invitation.create email: user.email, invited_by: self, invited_to: invited_to
    save
  end

  def can_play game
    # test in order of least likly to change soon
    can_play_by_age(game) && can_play_by_restriction_badges(game) && can_play_by_user_points(game) && can_play_by_credits(game)
  end

  def can_play_by_credits game
    ((credits || 0) >= game.costs).tap {|i_can_it|
      errors.add :base, I18n.t('users.errors.buying_game.insufficient_credits', need_credits: game.costs, have_credits: credits) unless i_can_it
    }
  end

  def can_play_by_user_points game
    (user_points >= game.min_points_required rescue true).tap {|i_can_it|
      errors.add :base, I18n.t('users.errors.buying_game.insufficient_point', need_points: game.min_points_required, have_points: user_points) unless i_can_it
    }
  end

  def can_play_by_age game
    (age >= game.minimum_age rescue true).tap {|i_can_it|
      errors.add :base, I18n.t('users.errors.buying_game.insufficient_age', need_age: game.minimum_age, have_age: age) unless i_can_it
    }
  end

  def can_buy game
    (can_play_by_age(game) && can_play_by_credits(game))
  end

  def can_play_by_restriction_badges game
    restriction_badge = game.restriction_badge
    return true unless game.restriction_badge
    (self.badges.include? restriction_badge).tap{|has_badge|
      errors.add :base, I18n.t('users.errors.buying_game.insufficient_badges', need_badges: restriction_badge.title) unless has_badge
    }
  end

  def age
    birthday.present? ? years_completed_since(birthday, Date.today) : 0
  end

  def start_mission mission
    user_mission = user_missions.where(mission_id: mission.id).first || user_missions.create(user: self, mission: mission, points: mission.start_points)
  end

  def owns_game game
    self.user_games.where("game_id = ?", game.id).present?
  end

  def earn_reward_badge_of_game game
    earn_user_badge game.reward_badge unless game.nil?
  end

  def earn_user_badge badge
    if self.has_user_badge badge
      raise StandardError.new("Badge #{badge.title} can't be earned")
    else
      add_badge badge
    end
  end

  def earn_credits credits
    self.credits += credits
    self.save
  end

  def has_user_badge badge
    self.badges.include? badge
  end

  def self.find_first_by_auth_conditions warden_conditions
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions).where(["lower(username) = :value OR lower(email) = :value", { :value => login.downcase }]).first
    else
      where(conditions).first
    end
  end

  #find friends on rylyty be theier facebook_ids
  # create friedschips if freinds found
  def self.find_friends_by_facebook_ids facebook_friends, sender   
    return [] if facebook_friends.nil?
    receivers = User.where(:facebook_id => facebook_friends)
    receiver_ids = []
    receivers.map {|receiver| receiver_ids << receiver.id}
    self.create_friend_feed_item sender, receiver_ids unless receiver_ids.empty?
    self.create_friendships sender, receivers unless receivers.empty?
    receiver_ids
  end

  def self.find_friends_by_emails emails, sender, create_friendship = true
    friends = User.where(:email => emails)
    self.create_friendships sender, friends unless friends.nil? || !create_friendship
    friends
  end

  def self.create_friend_feed_item sender, receiver_ids
    Notifications.publish 'write_my_news_feed_item',
      reference: self,
      sender: sender,
      receiver_ids: receiver_ids,
      event_type: User::EventTypes::FB_FRIEND_SIGNED_UP,
      feedable: sender
  end

  def become_friends_with another_user
    self.friendships.create friend: another_user
    save!
  end

  def destroy_friendship_with friend
    f = Friendship.find_friendship self.id, friend.id
    f.destroy if f.present?
  end

  def friends_with? another_user
    Friendship.where("(user_id = :me AND friend_id = :other) OR (user_id = :other AND friend_id = :me)", me: self.id, other: another_user.id).present?
  end

  def friends
    friends_by_me.to_a + friends_for_me.to_a
  end

  def friend_ids
    friends_by_me_ids.to_a + friends_for_me_ids.to_a
  end

  def self.create_friendships sender, friends
    friends.each do |friend|
      sender.become_friends_with friend unless sender.friends_with? friend
    end
  end

  def unpurchased_games
    Game.where('games.id NOT IN (SELECT game_id FROM user_games where user_id = ?)', id)
  end

  def purchasable_games
    unpurchased_games.where("costs <= ?", (credits||0))
  end

  def default_credits(credits=10)
    update_attributes(credits: credits)
  end

  def upload_facebook_avatar_async
    return if self.avatar_file_name
    Resque.enqueue(FacebookAvatarUploader, self.id)
  end

  def upload_facebook_avatar
    self.avatar = URI.parse(self.facebook_profile_url)
    self.save
  end

  def self.merge_rylyty_user_with_fb_user fb_user
    rylyty_registered_with_fb_credentials = User.find_by_email fb_user.email
    if rylyty_registered_with_fb_credentials.present?
      # overwrites eventually existing fb-credentials since current credentials come from facebook
      rylyty_registered_with_fb_credentials.update_attributes(facebook_id: fb_user.facebook_id,
                                                              facebook_profile_url: fb_user.facebook_profile_url)
      return rylyty_registered_with_fb_credentials
    end
    nil
  end

  protected

  def add_game game
    self.games << game
    user_games.find_by_game_id(game.id).tap do |user_game|
      self.user_tasks << game.tasks.map { |task|
         UserTask.create_for_task(task, user_game: user_game)
      }
    end
  end

  def add_badge badge
    self.badges << badge
    self.save
  end


  def facebook_user?
    facebook_id.present?
  end

end

class UserTask < ActiveRecord::Base

  module EventTypes
    STARTED = 'task_started'
    COMPLETED = 'task_completed'
    TIMED_OUT = 'task_timed_out'
    LIKE = 'task_liked'
  end

  module ApprovalStates
    ACTIVE = 'active'
    BLOCKED = 'blocked'
    REPORTED = 'reported'
  end

  belongs_to :user
  belongs_to :task
  belongs_to :user_game
  acts_as_list scope: :user_game
  has_many :feed_items, as: :feedable

  scope :completed, conditions:{state: :completed}
  scope :verified, conditions:{verification_state: :verified}
  scope :optional, conditions:{optional: true}
  scope :required, conditions:{optional: false}

  validates :task, associated: true, association_presence: true
  validates :user_game, associated: true, association_presence: true

  before_create :set_user
  delegate :timed_task?, to: :task

  attr_accessible :task, :user_game,
    :position, # need to make the position field accessible due to https://github.com/swanandp/acts_as_list/issues/50
    :approval_state, # later this will be managed with state_machine, but for now we keep it simple
    :comment,
    :started_at,
    :finished_at,
    :times_out_at,
    :feedable,
    :optional

  state_machine :verification_state, initial: :unverified, namespace: :verification do
    state :unverified
    state :verified

    after_transition to: :verified do |user_task, transition|
      user_game = user_task.user_game
      user_task.collect_rewards user_task.task.points, 'task_points'
      user = user_task.user
      user_task.collect_points user_task.task.points
      user_task.update_attributes approval_state: UserTask::ApprovalStates::ACTIVE
      
      user_game.task_verified

      if user_game.completed? 
        user_task.collect_rewards user_game.game.points, 'game_points'
        user_task.collect_rewards user_game.game.reward_badge.to_json, 'game_reward_badge' unless user_game.game.reward_badge.nil?
      end

      if !user.friend_ids.empty? || user_task.user_game.feed_visibility == UserGame::Visibility::COMMUNITY
        Notifications.publish 'write_friend_feed_item',
          reference: user_task.task,
          sender: user,
          receiver_ids: user.friend_ids,
          event_type: UserTask::EventTypes::COMPLETED,
          visibility: user_task.user_game.feed_visibility,
          feedable: user_task
      end
    end

    event :verify do
      transition from: :unverified, to: :verified
    end
  end

  state_machine :state, initial: :open do
    state :open
    state :started
    state :canceled
    state :completed

    # at the moment user_tasks get validated automatically after completed!
    after_transition to: :completed do |user_task, transition|
      Resque.remove_delayed(Workers::TimedTask, :user_task_id => user_task.id) if user_task.timed_task?
      user_task.update_attributes finished_at: DateTime.now
      user_task.verify_verification
    end

    after_transition to: :started do |user_task, after_transition|
      user = user_task.user

      if !user.friend_ids.empty? || user_task.user_game.feed_visibility == UserGame::Visibility::COMMUNITY
        Notifications.publish 'write_friend_feed_item', reference: user_task.task, sender: user, receiver_ids: user.friend_ids, event_type: UserTask::EventTypes::STARTED, visibility: user_task.user_game.feed_visibility, feedable: user_task
      end

      if user_task.timed_task?
        user_task.start_timed_task
      end

    end

    after_transition to: :canceled do |user_task, transition|
      user_task.user_game.task_canceled

      if transition.event == :time_out
        user_task.create_news_feed_item user_task.task, UserTask::EventTypes::TIMED_OUT
      end

      if user_task.timed_task?
        Resque.remove_delayed(Workers::TimedTask, :user_task_id => user_task.id)
        if user_task.finished_at.blank?
          user_task.update_attributes finished_at:  DateTime.now
        else
          # TODO task timed out after already being finished
        end
      end
    end

    event :start do
      transition from: :open, to: :started, if: :game_playable?
    end

    event :complete do
      # !heads-up! the 'from' state will be dynamicly defined by `#may_completed?`
      #            cannot use `from: :foo, to: :bar` syntax here
      transition all - [:canceled] => :completed, if: :may_completed?
    end

    event :cancel, :time_out do
      # !heads-up! cannot use `from: :foo, to: :bar` syntax here
      transition all - [:completed] => :canceled
    end

  end

  class << self
    # Register an Answer implementation.
    # All Answer classes which wish to get picked automaticly
    # using their {#match_task?} method have to register.
    #
    # Registration takes a priority which defines how specific
    # the Answer matches a Task.
    #
    # @param [Class] answer_class A reference to the Answer class.
    # @param [Fixnum] prio Priority describing how specific the Answer matches. (default: `5`)
    def register_answer(answer_class, prio = 5)
      @answer_classes ||= {}
      @answer_classes[prio] ||= []
      @answer_classes[prio] << answer_class
    end

    def match_task? task
      ##
      # Fallback to a "common" Task which dont require any special answer logic
      task.class == Task
    end

    # creates the correct Answer class for a given Task
    #
    # @param [Task] a task instance for which a Answer should be crated
    # @param [Hash] an optional options Hash to pass the the Answer's {ActiveRecord::Base#create} method
    def create_for_task task, opts = {}
      klass = answer_class_for_task task
      raise NotImplementedError.new("Missing Answer implementation for the Task type <#{task.class}>") unless klass

      klass.create opts.merge!(task: task, optional: task.optional)
    end

    private

    # Returns an reference to the registrated Answer class which
    # matches first (according to it's priority) or `nil` if none matches.
    def answer_class_for_task task
      @answer_classes.keys.sort.reverse.each do |prio|
        klass = @answer_classes[prio].detect { |k| k.match_task?(task) }
        return klass if klass
      end
      return nil
    end
  end

  def set_user
    self.user = user_game.user if user_id.blank?
  end

  def collect_reward
    reward_points = task.points
    reward_points += user_game.game.points if user_game.completed?
    reward = {points: reward_points}
    if user_game.game.reward_badge.present?
      badge = user_game.game.reward_badge
      reward.merge!({badge: {id: badge.id, title: badge.title, thumb: badge.image.url(:thumb),
                                      thumb_hi: badge.image.url(:thumb_hi) }})
    end
    reward
  end

  def create_news_feed_item obj, event_type, sender = self.user
    Notifications.publish 'write_my_news_feed_item',
      reference: obj,
      sender: sender,
      receiver_ids: [self.user.id],
      event_type: event_type,
      feedable: self
  end

  def start_timed_task
    now = DateTime.now
    self.update_attributes started_at: now, times_out_at: now + self.task.timeout_secs.seconds
    Resque.enqueue_at(self.times_out_at, Workers::TimedTask, self.id)
  end

  ##
  # Update attributes relevant to the answer of a task.
  # Automatically tries to {#complete} the task.
  # This method may be owerwritten in each "Answer" subclasses
  #
  # @param [Hash] Relevant attributes to update in order to answer this task
  def answer_with answer_attributes
    self.update_attributes answer_attributes
    complete
  end

  ##
  # Determinate whether this Task was answered (or processed in it's own manner)
  #
  # @note By default, +true+ is returned for the sake of easy testing.
  #   Thus this method shall be overwritten in subclasses
  #
  # @return [Booloean]
  def answered?; true end

  def report reporter
    ReportUserTaskMailer.report_task(self, reporter).deliver
  end

  def block
    self.update_attributes approval_state: UserTask::ApprovalStates::BLOCKED
  end

  def unblock
    self.update_attributes approval_state: UserTask::ApprovalStates::ACTIVE
  end

  def self.find_by_user_and_task_id user, task_id
    where(user_id: user.id, task_id: task_id).first
  end

  def collect_points points
    self.user.earn_points points
  end

  def collect_rewards points, context
    reward = self.reward || {}
    reward.merge!({context.to_sym => points})
    self.reward = reward
    self.save
  end

  def reward
    ActiveSupport::JSON.decode read_attribute(:reward) unless read_attribute(:reward).nil?
  end

  def reward=(m)
    write_attribute(:reward, m.to_json)
  end

  protected

    ##
    # helper to check if this user_task can be completed.
    # checks on the current user_task's state and if it is answered.
    #
    # @note cannot be named `can_completed?` because this would
    #       overwrite a statemachine method
    #
    # @return [Booloean]
    def may_completed?
      self.answered? && (self.state?(:started) || (!self.timed_task? && self.state?(:open)))
    end

    def game_playable?
      self.user_game.playable?
    end
end

##
# register the fallback with low prio
UserTask.register_answer UserTask, 2

Dir.glob(File.expand_path('../answers/*.rb', __FILE__)) { |file| require file }

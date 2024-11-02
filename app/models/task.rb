class Task < ActiveRecord::Base
  belongs_to :game
  acts_as_list scope: :game
  has_many :user_tasks
  has_many :feed_items, as: :feedable

  has_attached_file :icon, styles: { thumb_hi: "210x210>", thumb: "105x105>" },
      path: ":rails_root/public/assets/:attachment/games/:game_id/tasks/:id/:filename_:style"
  attr_accessible :description, :title, :short_description, :timeout_secs, :type, :icon, :points,
    :optional,
    :position # need to make the position field accessible due to https://github.com/swanandp/acts_as_list/issues/50

  validates :title, presence: true
  validates :type, presence: true, :if => lambda {|task| task.class == Task}

  # custom placeholder for icon-attachment-url
  Paperclip.interpolates :game_id do |attachment, style|
    attachment.instance.try(:game).try(:id) || -1
  end

  def find_latest_answers limit=10
    user_tasks.where("verification_state = ? AND (approval_state = ? OR approval_state = ?)", 'verified',  UserTask::ApprovalStates::ACTIVE,  UserTask::ApprovalStates::REPORTED).order(:updated_at).limit(limit)
  end

  ##
  # Overwrite this method in subclasses when the task
  # wants to advertise it's latest answers
  #
  # @return [Array<Task>]
  def find_latest_advertised_answers limit=10
    []
  end

  def timed_task?
    timeout_secs.present? && timeout_secs > 0
  end

end

Dir.glob(File.expand_path('../tasks/*.rb', __FILE__)) { |file| require file }
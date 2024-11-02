class Like < ActiveRecord::Base
  belongs_to :user
  belongs_to :user_task

  attr_accessible :user_id, :user_task_id

  validates :user_task_id, presence: true
  validates :user_task_id, uniqueness: {scope: :user_id, message: I18n.t("user_tasks.already_liked", locale: 'de') }
  validates :user, presence: true
  validate :user_task_must_be_completed

  def user_task_must_be_completed
    errors[:user_task] << I18n.t("user_tasks.not_valid_for_like")  if user_task.try(:state).try(:to_sym) != :completed
  end

  def self.likes_for_user_task user_task
    Like.joins(:user).where(user_task_id: user_task.id).order('username asc')
  end
end

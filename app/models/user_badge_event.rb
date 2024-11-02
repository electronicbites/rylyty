class UserBadgeEvent  < ActiveRecord::Base

  belongs_to :user
  belongs_to :badgeable_event
  has_one :badge, through: :badgeable_event, source: :badge

  attr_accessible :user, :badgeable_event

  validates :user, presence: true
  validates :badgeable_event, presence: true
  validates_each :badgeable_event do |record, attr, value|
    case attr
    when :badgeable_event
      next if record.user.nil? || record.badgeable_event.nil?
      existing_badge = UserBadgeEvent.joins(:badgeable_event).where(user_id: record.user.id, badgeable_events: { badge_id: record.badge.id }).first
      record.errors.add(attr, 'a badge can only be earned once') unless existing_badge.nil?
    end
  end

  alias_attribute :earned_at, :created_at

end

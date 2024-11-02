class MigrateUserBadgeData < ActiveRecord::Migration

  class UserBadgeEvent < ActiveRecord::Base
    belongs_to :user
    belongs_to :badgeable_event
    has_one :badge, through: :badgeable_event, source: :badge
    attr_accessible :user, :badgeable_event
  end

  class BadgeableEvent  < ActiveRecord::Base
    belongs_to :badge
    belongs_to :event_source, polymorphic: true
    attr_accessible :badge, :event_source, :context
  end

  class User < ActiveRecord::Base
    has_many :user_badge_events, dependent: :destroy
    has_many :badges, through: :user_badges
    has_many :user_badges
  end

  def up
    users = User.all
    users.each do |user|
      if (badges = user.user_badge_events.collect &:badge)
        user.badges = badges
      end
    end
  end
end
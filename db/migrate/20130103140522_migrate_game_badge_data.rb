class MigrateGameBadgeData < ActiveRecord::Migration

  class BadgeContext < ActiveRecord::Base
    has_many :badgeable_events, as: :event_source, dependent: :destroy
    attr_accessible :name, :badge, :badge_id
  end

  class BadgeableEvent  < ActiveRecord::Base
    belongs_to :badge
    belongs_to :event_source, polymorphic: true
    attr_accessible :badge, :event_source, :context
  end

  class Game  < ActiveRecord::Base
    module GameBadgeableEventTypes
      REWARD = 'reward'
      RESTRICTION = 'restriction'
    end
    has_many :reward_badgeable_event, as: :event_source, class_name: 'BadgeableEvent', conditions: { badgeable_events: { context: GameBadgeableEventTypes::REWARD } }, dependent: :destroy
    has_many :restriction_badgeable_events, as: :event_source, class_name: 'BadgeableEvent', conditions: { badgeable_events: { context: GameBadgeableEventTypes::RESTRICTION } }, dependent: :destroy
    attr_accessible :reward_badge, :restriction_badges
  end

  def up
    migrate_reward_badges
    migrate_restriction_badges
  end

  def migrate_reward_badges
    Game.all.each do |game|
      game.reward_badgeable_event.each do |badgeable_event|
        game.reward_badge_id = badgeable_event.badge_id
        game.save
      end
    end
  end

  def migrate_restriction_badges
    Game.all.each do |game|
      game.restriction_badgeable_events.each do |badgeable_event|
        game.restriction_badge_id = badgeable_event.badge_id
        game.save
      end
    end
  end
end

class FeedItem < ActiveRecord::Base
  belongs_to :feedable, :polymorphic => true
  attr_accessible :message, :event_type, :feed_visibility, :sender_id, :receiver_ids, :game_id, :task_id, :feedable

  def message
    JSON.parse read_attribute(:message)
  end

  def message=(m)
    write_attribute(:message, m.to_json)
  end

  def self.game_feed_items startkey, limit
    self.where(
        'event_type IN (:event_types) AND extract(epoch from created_at) > :startkey',
        {
          event_types: ['user_bought_game', 'game_completed', 'task_started', 'task_completed'],
          startkey: startkey
        }  
      ).limit(limit).order("created_at DESC")
  end

  # this is not final yet, so far the news feed only contains an item if an fb-friens signed up.
  # there will be more personal messages later
  # likes
  # invitation to a game
  # time_out
  def self.news_feed_items receiver_id, startkey, limit
    self.find(  
        :all, 
        limit: limit,
        order: 'created_at DESC',
        conditions: ['event_type IN (:event_types) AND receiver_ids @> :receiver_ids AND extract(epoch from created_at) > :startkey',
        event_types: [
          User::EventTypes::FB_FRIEND_SIGNED_UP, 
          UserTask::EventTypes::TIMED_OUT, 
          UserTask::EventTypes::LIKE,
          Invitation::EventTypes::INVITE_ACCEPTED,
          Invitation::EventTypes::GAME_INVITE_RECEIVED
        ],
        receiver_ids: [receiver_id].pg(:integer),
        startkey: startkey
        ]
      )
  end

  def self.friend_feed_items receiver_id, startkey, limit
    self.find(
        :all,
        limit: limit,
        order: 'created_at DESC',
        conditions: ['event_type IN (:event_types) AND receiver_ids @> :receiver_ids AND extract(epoch from created_at) > :startkey',
        event_types: [UserGame::EventTypes::COMPLETED, UserTask::EventTypes::STARTED, UserTask::EventTypes::COMPLETED],
        receiver_ids: [receiver_id].pg(:integer),
        startkey: startkey
        ]
      )
  end
end
object :@feed_item => :feed_item

attributes :id, :event_type

node(:sender) {|feed_item|
  partial "/api/v1/users/show", object: User.find(feed_item.sender_id)
}

child(:feedable => :feedable) {
  node(:type)   { |feedable| feedable.class.to_s }
  node(:object) { |feedable|
    if feedable.class <= Task
      partial "/api/v1/tasks/show", object: feedable
    elsif feedable.class <= UserTask
      partial "/api/v1/user_tasks/show", object: feedable
    elsif feedable.class <= Game
      partial "/api/v1/games/show", object: feedable
    elsif feedable.class <= User
     partial "/api/v1/users/show", object: feedable
    end
  }
}

node(:created_at) { |feed_item| feed_item.created_at.to_i }
#node(:avatar) {|feed_item| feed_item.message['avatar']}
node(:thumb) {|feed_item| feed_item.message['thumb']}
node(:thumb_hi) {|feed_item| feed_item.message['thumb_hi']}
node(:message) { |feed_item|

  opts = { }.merge Hash[ %w(title username credits points).map { |e|
    [e.to_sym, feed_item.message[e]] if feed_item.message[e].present?
  }]

  t("feeds.#{feed_item.event_type}", opts)
}
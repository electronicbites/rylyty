# require all worker classes
Dir[Rails.root + 'lib/workers/*.rb'].each {|file| require file }

Notifications.subscribe 'write_my_news_feed_item', MyNewsFeedWorker
Notifications.subscribe 'write_friend_feed_item', FriendFeedWorker
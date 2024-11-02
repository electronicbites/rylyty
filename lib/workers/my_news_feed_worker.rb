class MyNewsFeedWorker

  def self.perform event_name, *args
    features = args.last
    sender = features[:sender]
    
    item = FeedItem.create(
      event_type: features[:event_type], 
      message: self.message(features[:reference], sender, features[:feedable]), 
      feed_visibility: features[:visibility] || UserGame::Visibility::FRIENDS,
      sender_id: sender.id,
      receiver_ids: features[:receiver_ids],
      feedable: features[:feedable]
    )
  end

  def self.message obj, sender, feedable

    msg = {} # enter defaults here

    thumb = ''
    thumb_hi = ''

    if (obj.kind_of? Task)
      if (feedable.class == PhotoAnswer)
        thumb = feedable.photo.url(:thumb)
        thumb_hi = feedable.photo.url(:thumb_hi)
      end
      msg.merge!({
        title: obj.title,
        credits: obj.points,
        username: sender.username,
        thumb: thumb_hi,
        thumb_hi: thumb_hi 
      })
    elsif (obj.kind_of? Game)
      msg.merge!({
        title: obj.title,
        username: sender.username,
        thumb: feedable.image.url(:feed),
        thumb_hi: feedable.image.url(:feed_hi)
      })
    elsif (obj.kind_of? Invitation)
      if (feedable.class == Game)
        thumb = feedable.image.url(:thumb)
        thumb_hi = feedable.image.url(:thumb_hi)
      end
      if (feedable.class == User)
        thumb = feedable.avatar.url(:thumb)
        thumb_hi = feedable.avatar.url(:thumb_hi)
      end
      msg.merge!({
        username: sender.username,
        credits: 100,
        thumb: thumb,
        thumb_hi: thumb_hi
      })
    else
      msg.merge!({
        username: sender.username
      })
    end
   
    msg

  end
end
class FriendFeedWorker

  def self.perform event_name, *args
    features = args.last
    sender = features[:sender]
    obj = features[:reference]
      
    item = FeedItem.create(
      event_type: features[:event_type], 
      message: self.message(obj, sender, features[:feedable]), 
      feed_visibility: features[:visibility],
      sender_id: sender.id,
      receiver_ids: features[:receiver_ids],
      feedable: features[:feedable] 
      )

  end

  def self.message obj, sender, feedable
    msg = {
      title: obj.title,
      username: sender.username,
    } # enter defaults here
    if (obj.kind_of? Task)
      thumb = ''
      thumb_hi = ''
      if (feedable.class == PhotoAnswer)
        thumb = feedable.photo.url(:thumb)
        thumb_hi = feedable.photo.url(:thumb_hi)
      end
      msg.merge!({
        points: obj.points,
        thumb: thumb_hi,
        thumb_hi: thumb_hi
      })
    end
    if  (obj.kind_of? Game)
      msg.merge!({
        points: obj.points,
        thumb: feedable.image.url(:feed),
        thumb_hi: feedable.image.url(:feed_hi),
      })
    end
   
    msg
  end

end
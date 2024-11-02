class FacebookAvatarUploader
  
  # queue for resque
  @queue = :facebook_avatar_uploader

  # callback for resque-worker
  def self.perform user_id
    user = User.find(user_id)
    user.upload_facebook_avatar
  end
end
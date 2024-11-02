object :@user => :user
attributes :id, :username, :user_points, :credits

node(:avatar_thumb)    { |user| user.avatar.url(:thumb) }
node(:avatar_thumb_hi) { |user| user.avatar.url(:thumb_hi) }
node(:avatar_normal)    { |user| user.avatar.url(:normal) }
node(:avatar_normal_hi) { |user| user.avatar.url(:normal_hi) }
node(:avatar_feed)    { |user| user.avatar.url(:feed) }
node(:avatar_feed_hi) { |user| user.avatar.url(:feed_hi) }
node(:my_friend)       { |user| current_user.friends_with?(user) }

node(:badges, if: ->(user) { !user.nil? && !user.badges.empty? } ) do |user|
  partial("/api/v1/badges/index", object: user.badges)
end

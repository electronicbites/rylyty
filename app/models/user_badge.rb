class UserBadge < ActiveRecord::Base
  attr_accessible :user_id, :badge_id
  
  belongs_to :user
  belongs_to :badge
end

class UserMission < ActiveRecord::Base
  belongs_to :user
  belongs_to :mission
  
  attr_accessible :user, :mission, :points

end

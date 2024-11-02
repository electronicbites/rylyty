class Friendship < ActiveRecord::Base
  attr_accessible :friend_id, :user_id, :friend, :user

  belongs_to :user
  belongs_to :friend, class_name: "User"

  validate :friend_is_not_self?
  validates_each :user do |record, attr, value|
    f = find_friendship record.user_id, record.friend_id
    record.errors.add(attr, 'Friendship already exists') unless f.nil?
  end

  def friend_is_not_self?
    errors.add :base, 'user equals friend' unless user_id != friend_id 
  end

  def self.find_friendship user_id, friend_id
    where("(user_id = :user_id AND friend_id = :friend_id) OR (user_id = :friend_id AND friend_id = :user_id)", user_id:  user_id, friend_id: friend_id).first
  end
end

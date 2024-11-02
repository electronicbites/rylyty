class AddIndexToFriendshipsUserIdAndFriendId < ActiveRecord::Migration
  def up
    add_index :friendships, [:user_id]
    add_index :friendships, [:friend_id]
    add_index :friendships, [:user_id, :friend_id]
  end

  def down
    remove_index :friendships, column: [:user_id]
    remove_index :friendships, column: [:friend_id]
    remove_index :friendships, column: [:user_id, :friend_id]
  end
end

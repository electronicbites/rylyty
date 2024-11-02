class RenameFeedItemUserIdToSenderId < ActiveRecord::Migration
  def change
    rename_column :feed_items, :user_id, :sender_id
  end
end

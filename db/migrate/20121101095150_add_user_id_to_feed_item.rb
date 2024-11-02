class AddUserIdToFeedItem < ActiveRecord::Migration
  def change
    add_column :feed_items, :user_id, :integer
  end
end

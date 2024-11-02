class RemoveFeedTypeFromFeedItems < ActiveRecord::Migration
  def up
    remove_column :feed_items, :feed_type
  end

  def down
    add_column :feed_items, :feed_type, :string
  end
end

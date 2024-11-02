class AddFeedVisibilityToFeedItem < ActiveRecord::Migration
  def change
    add_column :feed_items, :feed_visibility, :string
  end
end

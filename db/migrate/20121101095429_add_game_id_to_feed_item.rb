class AddGameIdToFeedItem < ActiveRecord::Migration
  def change
    add_column :feed_items, :game_id, :integer
  end
end

class RemoveTaskAndGameIdFromFeedItem < ActiveRecord::Migration
  def change
    remove_column :feed_items, :task_id
    remove_column :feed_items, :game_id
  end
end

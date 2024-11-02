class AddTaskIdToFeedItem < ActiveRecord::Migration
  def change
    add_column :feed_items, :task_id, :integer
  end
end

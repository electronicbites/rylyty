class AddEventTypeToFeedItems < ActiveRecord::Migration
  def change
    add_column :feed_items, :event_type, :string
  end
end

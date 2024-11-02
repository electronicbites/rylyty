class AddReceiverIdsToFeedItem < ActiveRecord::Migration
  def change
    add_column :feed_items, :receiver_ids, :integer_array
  end
end

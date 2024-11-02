class CreateFeedItems < ActiveRecord::Migration
  def change
    create_table :feed_items do |t|
      t.string :feed_type
      t.text :message

      t.timestamps
    end
  end
end

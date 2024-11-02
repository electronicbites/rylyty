class AddFeedVisibilityToUserGame < ActiveRecord::Migration
  def change
    add_column :user_games, :feed_visibility, :string, :default => 'community'
  end
end

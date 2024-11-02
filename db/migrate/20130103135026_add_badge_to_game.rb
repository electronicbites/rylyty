class AddBadgeToGame < ActiveRecord::Migration
  def change
    add_column :games, :restriction_badge_id, :integer
    add_column :games, :reward_badge_id, :integer
  end
end

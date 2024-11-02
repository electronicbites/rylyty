class AddRewardToGame < ActiveRecord::Migration
  def change
     add_column :games, :reward_points, :integer, null: false, default: 0
  end
end

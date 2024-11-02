class RenameGameRewardPoints < ActiveRecord::Migration
  def change
    rename_column :games, :reward_points, :points
  end
end

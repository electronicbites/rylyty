class AddRewardToUserTask < ActiveRecord::Migration
  def change
    add_column :user_tasks, :reward, :text
  end
end

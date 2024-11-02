class AddPositionToUserTasks < ActiveRecord::Migration
  def change
    add_column :user_tasks, :position, :integer
  end
end

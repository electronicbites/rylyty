class RemoveVeryfiedFromUserTasks < ActiveRecord::Migration
  def up
    remove_column :user_tasks, :veryfied
  end

  def down
    add_column :user_tasks, :veryfied, :boolean
  end
end

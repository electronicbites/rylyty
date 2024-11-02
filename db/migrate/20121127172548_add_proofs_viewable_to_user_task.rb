class AddProofsViewableToUserTask < ActiveRecord::Migration
  def change
    add_column :tasks, :user_task_viewable, :boolean, :default => true
  end
end

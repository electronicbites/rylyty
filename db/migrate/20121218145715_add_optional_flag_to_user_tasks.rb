class AddOptionalFlagToUserTasks < ActiveRecord::Migration
  def change
    add_column :user_tasks, :optional, :boolean, :default => false
  end
end

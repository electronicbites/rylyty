class AddTimelimitToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :timeout_secs, :integer
    add_column :user_tasks, :started_at, :datetime
    add_column :user_tasks, :finished_at, :datetime
  end
end

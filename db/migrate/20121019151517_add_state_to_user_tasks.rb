class AddStateToUserTasks < ActiveRecord::Migration
  def change
    add_column :user_tasks, :state, :string
  end
end

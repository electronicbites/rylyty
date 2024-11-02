class AddStiTypeToUserTasks < ActiveRecord::Migration
  def change
    add_column :user_tasks, :type, :text
  end
end

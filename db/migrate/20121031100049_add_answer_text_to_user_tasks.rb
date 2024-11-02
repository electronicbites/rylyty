class AddAnswerTextToUserTasks < ActiveRecord::Migration
  def change
    add_column :user_tasks, :answer, :text
  end
end

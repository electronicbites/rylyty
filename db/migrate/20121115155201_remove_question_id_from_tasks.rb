class RemoveQuestionIdFromTasks < ActiveRecord::Migration
  def up
    remove_column :tasks, :question_id
  end

  def down
    add_column :tasks, :question_id, :integer
  end
end

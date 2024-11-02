class ChangeTasksQuestionToText < ActiveRecord::Migration
  def up
    change_column :tasks, :question, :text
  end

  def down
    change_column :tasks, :question, :string
  end
end

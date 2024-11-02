class AddDefaultTaskType < ActiveRecord::Migration
  def up
    change_column :tasks, :type, :text, null: false, default: 'QuestionTask'
  end

  def down
    change_column :tasks, :type, :text
  end
end

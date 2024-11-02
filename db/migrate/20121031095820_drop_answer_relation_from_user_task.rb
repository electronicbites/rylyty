class DropAnswerRelationFromUserTask < ActiveRecord::Migration
  def up
    remove_column :user_tasks, :answer_id
    remove_column :user_tasks, :answer_type
  end

  def down
    add_column :user_tasks, :answer_id, :integer
    add_column :user_tasks, :answer_type, :string
  end
end

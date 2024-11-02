class AddAnswerToUserTask < ActiveRecord::Migration
  def change
    add_column :user_tasks, :answer_id, :integer
    add_column :user_tasks, :answer_type, :string
  end
end

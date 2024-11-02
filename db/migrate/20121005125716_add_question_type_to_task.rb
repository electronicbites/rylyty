class AddQuestionTypeToTask < ActiveRecord::Migration
  def change
    add_column :tasks, :question_type, :string
    add_column :tasks, :question_id, :integer
  end
end

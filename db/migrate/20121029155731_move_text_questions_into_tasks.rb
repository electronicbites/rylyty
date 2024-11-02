class MoveTextQuestionsIntoTasks < ActiveRecord::Migration
  def up
    drop_table :text_questions
    add_column :tasks, :question, :string
  end

  def down
    create_table :text_questions do |t|
      t.text :question

      t.timestamps
    end
    remove_column :tasks, :question
  end
end

class CreateTextQuestions < ActiveRecord::Migration
  def change
    create_table :text_questions do |t|
      t.text :question

      t.timestamps
    end
  end
end

class CreatePhotoQuestions < ActiveRecord::Migration
  def change
    create_table :photo_questions do |t|
      t.text :description

      t.timestamps
    end
  end
end

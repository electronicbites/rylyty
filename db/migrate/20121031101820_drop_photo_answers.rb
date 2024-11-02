class DropPhotoAnswers < ActiveRecord::Migration
  def up
    drop_table :photo_answers
  end

  def down
    create_table :photo_answers do |t|
      t.string :photo_file_name
      t.string :photo_content_type
      t.integer :photo_file_size
      t.datetime :photo_updated_at
      t.text :comment

      t.timestamps
    end
  end
end

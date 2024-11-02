class AddPhotoToUserTasks < ActiveRecord::Migration
  def change
    add_column :user_tasks, :photo_file_name, :text
    add_column :user_tasks, :photo_content_type, :text
    add_column :user_tasks, :photo_file_size, :integer
    add_column :user_tasks, :photo_updated_at, :datetime
  end
end

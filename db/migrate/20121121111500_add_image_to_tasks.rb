class AddImageToTasks < ActiveRecord::Migration
  def change
    add_attachment :tasks, :icon
  end
end

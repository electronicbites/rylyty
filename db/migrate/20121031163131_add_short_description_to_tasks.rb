class AddShortDescriptionToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :short_description, :string
  end
end

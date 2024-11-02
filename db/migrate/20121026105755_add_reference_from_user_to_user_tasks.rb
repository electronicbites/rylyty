class AddReferenceFromUserToUserTasks < ActiveRecord::Migration
  def change
    change_table :user_tasks do |t|
      t.references :user
    end
  end
end

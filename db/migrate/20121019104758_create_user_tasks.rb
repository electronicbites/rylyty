class CreateUserTasks < ActiveRecord::Migration
  def change
    create_table :user_tasks do |t|
      t.integer :task_id
      t.integer :user_game_id
      t.boolean :veryfied
      t.text :comment

      t.timestamps
    end
  end
end

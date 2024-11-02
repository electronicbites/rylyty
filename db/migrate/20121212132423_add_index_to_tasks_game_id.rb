class AddIndexToTasksGameId < ActiveRecord::Migration
  def up
    add_index :tasks, [:game_id]
  end

  def down
    remove_index :tasks, [:game_id]
  end
end

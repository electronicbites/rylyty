class AddIndexToUserGamesUserIdAndGameId < ActiveRecord::Migration
  def up
    add_index :user_games, [:user_id]
    add_index :user_games, [:game_id]
    add_index :user_games, [:user_id, :game_id]
  end

  def down
    remove_index :user_games, column: [:user_id]
    remove_index :user_games, column: [:game_id]
    remove_index :user_games, column: [:user_id, :game_id]
  end
end

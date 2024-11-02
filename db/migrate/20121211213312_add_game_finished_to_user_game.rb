class AddGameFinishedToUserGame < ActiveRecord::Migration
  def change
    add_column :user_games, :finished_at, :datetime
  end
end

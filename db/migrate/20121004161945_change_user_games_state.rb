class ChangeUserGamesState < ActiveRecord::Migration
  def change
    change_column(:user_games, :state, :string)
  end
end

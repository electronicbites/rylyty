class AddImageToGames < ActiveRecord::Migration
  def change
    add_attachment :games, :image
  end
end

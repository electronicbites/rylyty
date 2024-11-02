class AddMinPointsRequiredToGames < ActiveRecord::Migration
  def change
    add_column :games, :min_points_required, :integer
  end
end

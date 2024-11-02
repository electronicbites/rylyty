class AddMinimumAgeToGames < ActiveRecord::Migration
  def change
    add_column :games, :minimum_age, :integer
  end
end

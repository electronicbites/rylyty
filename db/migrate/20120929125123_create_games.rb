class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.string :name
      t.text :description
      t.integer :time_limit
      t.integer :credits

      t.timestamps
    end
  end
end

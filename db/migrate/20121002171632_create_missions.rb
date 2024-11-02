class CreateMissions < ActiveRecord::Migration
  def change
    create_table :missions do |t|
      t.integer :start_points, :default => 0

      t.timestamps
    end
    
    create_table :mission_games do |t|
      t.references :mission
      t.references :game
    end
    
    create_table :user_missions do |t|
      t.references :user
      t.references :mission
      t.integer :points, :default => 0

      t.timestamps
    end
  end
end

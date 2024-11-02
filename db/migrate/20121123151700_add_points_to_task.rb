class AddPointsToTask < ActiveRecord::Migration
  def change
     add_column :tasks, :points, :integer, null: false, default: 0
  end
end

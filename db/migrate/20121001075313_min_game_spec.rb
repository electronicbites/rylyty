class MinGameSpec < ActiveRecord::Migration
  def change
    add_column :users, :user_points, :integer, default: 0

    rename_column :games, :name, :title
    rename_column :games, :credits, :costs
    add_column :games, :short_description, :string
    add_column :games, :author_id, :integer
  end
end

class AddContextToBadge < ActiveRecord::Migration
  def change
    add_column :badges, :context, :hstore
    add_index :badges, [:context]
  end
end

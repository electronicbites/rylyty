class AddIndexToTagsContext < ActiveRecord::Migration
  def up
    add_index :tags, [:context]
  end

  def down
    remove_index :tags, [:context]
  end
end

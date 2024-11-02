class AddOptionalFlagToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :optional, :boolean, :default => false
  end
end

class AddTimesOutAtUserTask < ActiveRecord::Migration
  def change
    add_column :user_tasks, :times_out_at, :datetime
  end
end

class AddStiTypeToTasks < ActiveRecord::Migration
  def up
    # no, we dont rename the column, as they contain incompatible values
    add_column :tasks, :type, :text
    remove_column :tasks, :question_type
  end

  def down
    add_column :tasks, :question_type, :text
    remove_column :tasks, :type
  end
end

class AddApprovalStateToUserTask < ActiveRecord::Migration
  def change
    add_column :user_tasks, :approval_state, :text
  end
end

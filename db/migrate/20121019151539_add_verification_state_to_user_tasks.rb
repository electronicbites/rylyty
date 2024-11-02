class AddVerificationStateToUserTasks < ActiveRecord::Migration
  def change
    add_column :user_tasks, :verification_state, :string
  end
end

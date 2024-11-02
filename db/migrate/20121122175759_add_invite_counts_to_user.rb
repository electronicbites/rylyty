class AddInviteCountsToUser < ActiveRecord::Migration
  def change
    add_column :users, :beta_invitations_budget, :integer, default: 0
    add_column :users, :beta_invitations_issued, :integer, default: 0
  end
end

class RenameEmailForBetaUsers < ActiveRecord::Migration
  def change
    rename_column :beta_users, :email_addr, :email
  end
end

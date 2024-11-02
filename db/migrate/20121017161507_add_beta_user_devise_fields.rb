class AddBetaUserDeviseFields < ActiveRecord::Migration
  def change
    add_column :beta_users, :confirmation_token, :string
    add_column :beta_users, :confirmation_sent_at, :datetime
    add_column :beta_users, :confirmed_at, :datetime
  end 
end

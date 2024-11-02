class RenameBetaVolunteerToBetaUsers < ActiveRecord::Migration
  def change
    rename_table :beta_volunteers, :beta_users
  end 
end

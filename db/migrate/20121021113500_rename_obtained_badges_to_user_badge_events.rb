class RenameObtainedBadgesToUserBadgeEvents < ActiveRecord::Migration
  def change
    remove_column :obtained_badges, :badge_id
    rename_table :obtained_badges, :user_badge_events
  end 
end

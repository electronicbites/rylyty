class AddFaceBookProfileUrlToUsers < ActiveRecord::Migration
  def change
    add_column :users, :facebook_profile_url, :text
    add_column :users, :facebook_access_token, :text
  end
end

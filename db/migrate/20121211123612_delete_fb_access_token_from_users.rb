class DeleteFbAccessTokenFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :facebook_access_token
  end
end

class AddInfoFieldsToDownloads < ActiveRecord::Migration
  def change
    add_column :downloads, :client_ip, :string
    add_column :downloads, :user_agent, :string
    add_column :downloads, :udid, :string
  end
end

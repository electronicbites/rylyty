class AddDeviceTokenToUsers < ActiveRecord::Migration
  def change
    add_column :users, :device_token, :integer
  end
end

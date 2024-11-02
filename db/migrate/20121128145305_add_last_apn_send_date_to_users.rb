class AddLastApnSendDateToUsers < ActiveRecord::Migration
  def change
    add_column :users, :last_apn_send_date, :timestamp
  end
end

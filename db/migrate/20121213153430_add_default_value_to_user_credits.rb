class AddDefaultValueToUserCredits < ActiveRecord::Migration
  def change
    User.where(credits: nil).each{|u| u.credits = 0; u.save}
    change_column :users, :credits, :integer, :default => 0
  end
end

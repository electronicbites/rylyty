class AddNewsletterToBetaUsers < ActiveRecord::Migration
  def change
    add_column :beta_users, :newsletter, :boolean
  end
end

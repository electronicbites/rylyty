class AddNewsletterConfirmationToBetaUsers < ActiveRecord::Migration
  def change
    add_column :beta_users, :newsletter_confirmation_token, :string
    add_column :beta_users, :newsletter_confirmation_sent_at, :datetime
    add_column :beta_users, :newsletter_confirmed_at, :datetime
  end
end

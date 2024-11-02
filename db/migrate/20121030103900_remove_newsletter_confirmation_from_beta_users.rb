class RemoveNewsletterConfirmationFromBetaUsers < ActiveRecord::Migration
  def change
    remove_column :beta_users, :newsletter_confirmation_token
    remove_column :beta_users, :newsletter_confirmation_sent_at
    remove_column :beta_users, :newsletter_confirmed_at
  end
end

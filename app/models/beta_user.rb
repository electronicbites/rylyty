class BetaUser < ActiveRecord::Base
  attr_accessible :email, :confirmation_token, :confirmed_at, :newsletter
  validates :email, presence: true, uniqueness: true
  validates_format_of     :email, :with  => Devise::email_regexp

  def self.create_beta_user_with_token attributes
    BetaUser.new attributes.merge({confirmation_token: Devise.friendly_token})
  end

  def send_confirmation!
    BetaUserMailer.register_beta_user(self).deliver
    self.confirmation_sent_at = Time.now
    save!
  end

  def confirm!
    update_attributes(confirmation_token: nil, confirmed_at: Time.now)
  end

  def confirmed?
    confirmation_token.nil? && confirmed_at.present?
  end

end

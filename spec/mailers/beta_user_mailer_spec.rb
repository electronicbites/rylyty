require 'spec_helper'

I18n.locale = 'de'

describe BetaUserMailer do

  describe 'registration confirmation' do
    let(:beta_user) {FactoryGirl.create(:beta_user, newsletter: true, confirmation_token: Devise.friendly_token)}
    let(:to) { beta_user.email }
    subject  { BetaUserMailer.register_beta_user beta_user }
  
    it 'has correct subject' do
      should have_subject(/Anmeldung bei rylyty.com/)
    end
  
    it 'has newsletter-info-message if beta_user wants newsletter' do
      should have_body_text(/Newsletter/)
    end
  
    it 'has message for link' do
      should have_body_text(/Bitte klicke zur/)
    end
  
    it 'has link for activation' do
      should have_body_text(/#{beta_user.confirmation_token}/)
    end
  end

  describe 'registration confirmation' do
    let(:beta_user) {FactoryGirl.create(:beta_user, newsletter: false, confirmation_token: Devise.friendly_token)}
    let(:to) { beta_user.email }
    subject  { BetaUserMailer.register_beta_user beta_user }
  
    it 'has no newsletter-info-message if beta_user does not want newsletter' do
      should_not have_body_text(/Newsletter/)
    end
  end
  
end
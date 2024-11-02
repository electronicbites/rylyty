require 'spec_helper'

feature 'invitation signup' do

  let (:invitig_user)  { FactoryGirl.create(:user) }
  let (:invitation)    { FactoryGirl.create(:invitation) }
  let (:token)         { invitation.token }
  let (:invitee_email) { invitation.email }

  before(:each) do
    I18n.locale = 'de'
    #@request.env["devise.mapping"] = Devise.mappings[:user]
  end

  scenario 'desktop user accepts invitation' do
    pending "add test for the invitation form /users/invitation/accepts?token=#{token}"
    # get "/users/invitation/accepts?token=#{token}"
    # p page.html
  end
end
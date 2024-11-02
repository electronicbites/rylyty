require 'spec_helper'

BETA_USER_FORM_ID = 'new_beta_user'
BETA_USER_EMAIL_TEXTFIELD_ID = 'beta_user_email'
NEWSLETTER_CHECKBOX_ID = 'beta_user_newsletter'

feature 'beta_registration' do

  scenario 'beta user roundtrip', js: true do
    BetaUser.destroy_all
    clear_emails
    I18n.locale = 'de'
    beta_user_email = 'testfoo@example.com'
    visit '/'
    find_by_id(BETA_USER_FORM_ID).should be_true
    find_by_id(NEWSLETTER_CHECKBOX_ID).should be_true
    fill_in BETA_USER_EMAIL_TEXTFIELD_ID, with: beta_user_email
    expect {
      within(find_by_id(BETA_USER_FORM_ID)) do
        find("button[@type=submit]").click
      end
      wait_for_ajax
      page.should have_content('Das hat geklappt. Du bekommst jetzt eine E-Mail mit einem Aktivierungslink.')
    }.to change(BetaUser, :count).by(1)

    open_email beta_user_email
    current_email = emails_sent_to(beta_user_email).first
    current_email.should have_content 'du hast dich gerade bei rylyty.com registiert'
    current_email.find("a").click

    page.should have_content('Liebst du es auch, wenn ein Plan funktioniert?')
    beta_user = BetaUser.where(email: beta_user_email).first
    beta_user.should be_confirmed
  end


  scenario 'wrong email ', js: true do
    clear_emails
    I18n.locale = 'de'
    beta_user_email = 'Claudia K.'
    visit '/'
    expect {
      within(find_by_id(BETA_USER_FORM_ID)) do
        find("button[@type=submit]").click
      end
      wait_for_ajax
    }.to_not change(BetaUser, :count)
  end

end
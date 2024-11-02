require 'spec_helper'

feature 'landing page' do

  scenario "signing up with email address" do
    visit '/'
    page.should have_css('form#new_beta_user input#beta_user_email')
    page.should have_css('form#new_beta_user button#btn-dabei')

    page.within("#new_beta_user") do
      fill_in 'beta_user_email', :with => 'user@example.com'
      click_button 'btn-dabei'
    end
  end

end

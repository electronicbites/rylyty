require 'spec_helper'

I18n.locale = 'de'

feature 'cockpit - badge' do

  let(:admin) { FactoryGirl.create(:admin_user, password: 'secret') }
  let(:badge) { FactoryGirl.create(:badge) }

  before(:each) do
    sign_in_as_admin admin, 'secret'
  end

  scenario 'create badge', js: true do
    visit "/cockpit/badges/new"
    
    fill_in 'badge_title', with: 'badge title'
    
    expect {
      find("input[@name='commit']").click
      has_no_field?("input[@name='commit']").should be_true
    }.to change { Badge.count }.by(1)
  end

  scenario 'edit badge', js: true do
    visit "/cockpit/badges/#{badge.id}/edit"
    
    new_badge_title = "#{badge.title}_changed"
    fill_in 'badge_title', with: new_badge_title
    
    expect {
      find("input[@name='commit']").click
      has_no_field?("input[@name='commit']").should be_true
    }.to change { badge.reload.title }.to(new_badge_title)
  end
  
end

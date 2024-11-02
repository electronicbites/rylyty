require 'spec_helper'

feature 'download_link' do

  scenario 'reach download link limit' do
    num_downloads = 4
    @download_link = FactoryGirl.create(:download_link, num_downloads: num_downloads)
    (1..(num_downloads+1)).each do |i|
      visit "/get-beta/#{@download_link.sha}"
      if i <= num_downloads
        page.status_code.should == 200
      else
        page.status_code.should == 403
        page.should have_content('limit exceeded')
      end
    end
  end
  
end 

require 'spec_helper'

describe DownloadController do
  render_views

  describe "GET 'get-beta'" do

    it "returns access denied for invalid sha" do
      get 'get_beta', {sha: 'invalid_sha'}
      response.response_code.should == 403
    end

    it "returns 'itms-service' url for installation on iPhone" do
      download_link = FactoryGirl.create(:download_link, num_downloads: 1)
      request.env['X_MOBILE_DEVICE'] = true
      get 'get_beta', {sha: download_link.sha}
      response.response_code.should == 200
      response.body.should include '\'itms-services://?'
      response.body.should include download_manifest_beta_app_url({sha: download_link.sha})
    end

    it "returns ipa-file url for download on desktop" do
      download_link = FactoryGirl.create(:download_link, num_downloads: 1)
      request.env['X_MOBILE_DEVICE'] = false
      get 'get_beta', {sha: download_link.sha}
      response.response_code.should == 200
      response.body.should include("<html>", "</html>", "rylyty.ipa?AWSAccessKeyId=#{AWS.config.access_key_id}&Expires=#{Time.now.to_i.to_s[0..5]}")
    end

    it "returns access denied for exceeded sha" do
      download_link = FactoryGirl.create(:download_link, num_downloads: 1)
      FactoryGirl.create(:download, download_link: download_link)
      get 'get_beta', {sha: download_link.sha}
      response.response_code.should == 403
    end
  end

  describe "GET 'manifest.plist'" do

    it "returns access denied for invalid sha" do
      get 'get_beta_manifest', {sha: 'invalid_sha'}
      response.response_code.should == 403
    end

    it "returns access denied for exceeded sha" do
      download_link = FactoryGirl.create(:download_link, num_downloads: 1)
      FactoryGirl.create(:download, download_link: download_link)
      get 'get_beta_manifest', {sha: download_link.sha}
      response.response_code.should == 403
    end

    it "manifest includes signed url to ipa-file" do
      download_link = FactoryGirl.create(:download_link, num_downloads: 1)
      request.env['X_MOBILE_DEVICE'] = false
      get 'get_beta_manifest', {sha: download_link.sha}
      response.response_code.should == 200
      response.body.should include("<plist version=\"1.0\">", "</plist>", "rylyty.ipa?AWSAccessKeyId=#{AWS.config.access_key_id}&amp;Expires=#{Time.now.to_i.to_s[0..5]}")
    end

  end

end

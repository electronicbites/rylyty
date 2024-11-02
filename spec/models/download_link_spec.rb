require 'spec_helper'

describe DownloadLink do
  
  describe '#validation' do
    def download_link opts = {}
      FactoryGirl.build :download_link, opts
    end

    it 'url requires sha-placeholder' do
      download_link = download_link(url: 'http://test.dev/')
      download_link.should_not be_valid
      download_link = download_link(url: 'http://test.dev/:sha')
      download_link.should be_valid
    end

    it 'sha should be auto_generated' do
      download_link = FactoryGirl.create(:download_link, sha: nil)
      download_link.sha.nil?.should be_false
      download_link.sha.length.should >= 1
    end

    it 'url and sha should be immutable' do
      download_link = FactoryGirl.create(:download_link)
      
      lambda { download_link.update_attribute(url: "http://#{Devise.friendly_token}.dev/:sha") }.should raise_error
      lambda { download_link.update_attribute(sha: Devise.friendly_token) }.should raise_error
    end
  end
  
  describe '#exports' do
    def csv_path
      data_dir_path = Rails.root.join('tmp', 'spec_data')
      data_dir_path.mkpath unless data_dir_path.exist?
      data_dir_path.join('download_links.csv')
    end

    it 'should export bundle-associated download_links into csv-file' do
      download_link_1 = FactoryGirl.create(:download_link)
      download_link_2 = FactoryGirl.create(:download_link)
      
      DownloadLink.export_csv(csv_path, download_link_1.bundle)
      
      csv_content = csv_path.read

      csv_content.match(Regexp.new(download_link_1.generate_url)).nil?.should be_false
      csv_content.match(Regexp.new(download_link_2.generate_url)).nil?.should be_false
    end

    it 'should not export other-bundle-associated download_links into csv-file' do
      download_link_1 = FactoryGirl.create(:download_link)
      download_link_2 = FactoryGirl.create(:download_link)
      
      DownloadLink.export_csv(csv_path, "other_#{download_link_1.bundle}")
      
      csv_content = csv_path.read

      csv_content.match(Regexp.new(download_link_1.generate_url)).nil?.should be_true
      csv_content.match(Regexp.new(download_link_2.generate_url)).nil?.should be_true
    end
  end
  
  describe '#downloads' do
    it 'should have limited number of downloads' do
      download_link = FactoryGirl.create(:download_link, num_downloads: 2)
      
      download_1 = FactoryGirl.create(:download, download_link: download_link)
      download_2 = FactoryGirl.create(:download, download_link: download_link)
      download_3 = FactoryGirl.build(:download, download_link: download_link)
      
      download_3.should_not be_valid
    end
  end

end

ActiveAdmin.register DownloadLink do
    menu :label => "Download Links", :parent => "Beta"
    # hide sha
    form do |f|
      f.inputs "Details" do
        f.input :url, hint: "http://#{request.env['HTTP_HOST']}/_route_with_:sha_placeholder"
        f.input :bundle
        f.input :num_downloads
      end
      f.buttons
    end
    
    csv do
      column :num_downloads
      column('url') { |download_link| "#{download_link.generate_url}" }
    end
  
end

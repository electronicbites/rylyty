ActiveAdmin.register Invitation do
  menu :label => "Offene Einladungen", :parent => "Benutzer"
  config.clear_sidebar_sections!

   index do
    column :token
    column :email
    column :sent_at
    column :accepted_at
    column :invited_by_id do |invitation|
      user = User.find invitation.invited_by_id
      user.name unless !user
    end
    column :download_link do |invitation|
      dl = DownloadLink.find(invitation.download_link_id) unless !dl
    end
   end  
end

ActiveAdmin.register User do

  menu :label => "Benutzer", :parent => "Benutzer"

  index do
    column :avatar do |user|
      image_tag user.avatar.url(:thumb)    
    end
    column :username
    column :email
    column :created_at
    column :current_sign_in_at
    column :last_sign_in_at
    column :current_sign_in_ip
    column :last_sign_in_ip
    default_actions
  end

  form do |f|
    if !f.object.new_record?
      
      f.inputs "Details" do
        f.input :avatar, as: :file, hint: f.template.image_tag(f.object.avatar.url(:thumb)), input_html: {style: 'display: none;'}
        f.input :username
        f.input :email
        f.input :birthday
        f.input :credits
      end

      f.inputs "Facebook Details" do
        f.input :facebook_profile_url, as: :string, input_html: {readonly: true}
      end

      f.buttons
    end
  end
  
end

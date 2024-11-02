ActiveAdmin.register Badge do

  index  do
    column :title
    column :image do |badge|
      image_tag badge.image.url(:thumb)  if badge.respond_to? 'image'  
    end
    column :created_at
    column :updated_at
    default_actions
  end
  
  show do |b|
    attributes_table do
      row :title
      row :description
      row :image do
        image_tag(b.image.url(:thumb_hi))
      end
      row :created_at
      row :updated_at
    end
    active_admin_comments
  end

  form do |f|
    if !f.object.new_record?                      
      f.inputs "Badge Details" do       
        f.input :title                  
        f.input :description
        f.input :context, as: :text, input_html: {style: 'width: 500px; height: 20px'}         
        f.input :image, f.object.respond_to?('image') ? { hint: f.template.image_tag(f.object.image.url(:thumb_hi)) } : {}
      end                               
      f.buttons
    else
      f.inputs "Badge Details" do       
        f.input :title                  
        f.input :description       
        f.input :image, f.object.respond_to?('image') ? { hint: f.template.image_tag(f.object.image.url(:thumb_hi)) } : {}
      end                               
      f.buttons
    end                     
  end                                 
  
end

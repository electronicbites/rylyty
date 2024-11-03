ActiveAdmin.register UserTask do

  menu :label => "Beweise", :parent => "Benutzer"

  member_action :block, :method => :post do
    user_task = UserTask.find(params['id'])
    user_task.block
    redirect_to cockpit_user_tasks_path
  end

  member_action :unblock, :method => :post do
    user_task = UserTask.find(params['id'])
    user_task.unblock
    redirect_to cockpit_user_tasks_path
  end

  index  do

    column :user
    column :email do |user_task|
      user_task.user.email unless user_task.user.nil?
    end
    column :state
    column :verification_state
    column :photo do |user_task|
      "Photo not available"
#      image_tag user_task.photo.url(:thumb)  if user_task.respond_to? 'photo'
    end
    column :answer
    column :approval_state
    default_actions
    column "Blockieren" do |user_task|
      link_to 'Blockieren', block_cockpit_user_task_path(user_task), {method: :post}
    end
    column "Freischalten" do |user_task|
      link_to 'Freischalten', unblock_cockpit_user_task_path(user_task), {method: :post}
    end
  end

  show do |ad|
    attributes_table do
      row :type
      row :user
      row :task
      row :game do
        ad.user_game.game.title
      end
      row :photo do
        "Photo not available"
        # image_tag(ad.photo.url(:thumb_hi))
      end
      row :answer
      row :started_at
      row :finished_at
      row :comment
      row :state
      row :verification_state
      row :approval_state
      row :position
      row :created_at
      row :updated_at

    end
    active_admin_comments
  end

  form do |f|

    # f.inputs "Details" do
    #   #f.input :avatar, as: :file, hint: f.template.image_tag(f.object.avatar.url(:thumb)), input_html: {style: 'display: none;'}
    #   f.input :user
    #   f.input :task, input_html: {readonly: true}
    #   f.input :comment
    # end

    f.inputs "Status" do
      f.input :approval_state, as: :string
    end

    f.buttons
  end

end

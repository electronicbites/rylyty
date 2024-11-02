ActiveAdmin.register Game do
    
    # redirect links/requests from active_admin interface
    member_action :show, :method => :get do
      redirect_to edit_cockpit_game_editor_path id: params[:id]
    end
    
    # redirect links/requests from active_admin interface
    member_action :edit, :method => :get do
      redirect_to edit_cockpit_game_editor_path id: params[:id]
    end
  
end

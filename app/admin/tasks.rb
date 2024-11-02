ActiveAdmin.register Task do

  menu false
    
    config.clear_action_items! # this will prevent the 'new button' showing up

    # redirect links/requests from active_admin interface
    member_action :show, :method => :get do
      task = Task.find(params[:id])
      redirect_to edit_cockpit_game_editor_path id: task.game.id, task_id: task.id, tasks: true
    end
    
    # redirect links/requests from active_admin interface
    member_action :edit, :method => :get do
      task = Task.find(params[:id])
      redirect_to edit_cockpit_game_editor_path id: task.game.id, task_id: task.id, tasks: true
    end
  
end

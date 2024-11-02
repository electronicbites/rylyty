class Api::V1::TasksController < Api::BaseController
  respond_to :json
  before_filter :authenticate_user!

  def index
    @tasks = Game.find(params[:game_id]).tasks
    render 'index'
  end

  def show
    @task = Task.find(params[:id])
    @user_tasks = @task.find_latest_advertised_answers
    render 'show'
  end
end
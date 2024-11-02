class Api::V1::Account::TasksController < Api::BaseController
  respond_to :json
  before_filter :authenticate_user!
  before_filter :fetch_user_task, except: :index

  def index
    @user_task = Game.find(params[:game_id]).tasks
    render 'api/v1/user_tasks/index'
  end

  def show
    render 'api/v1/tasks/show'
  end

  def update
    @user_task.update_attributes comment: params['comment']
    render 'api/v1/tasks/show'
  end

  def start
    @user_task.start
    if @user_task.state == 'started'
      render 'api/v1/tasks/show'
    else
      render json:{ success: false, message:  I18n.t('user_tasks.cannot_play') }, status: 200
    end
  end

  def cancel
    @user_task.cancel
    render 'api/v1/tasks/show'
  end

  def answer
    return record_not_found(message: I18n.t("user_tasks.task_already_answered"), status: 406) if @user_task.answered?
    @user_task.answer_with params[:answer_with]
    render 'api/v1/tasks/show'
  end

  private
    def fetch_user_task
      if params[:action] == 'answer' || params[:action] == 'start'
        message = I18n.t("user_tasks.buy_game_first")
      else
        message = I18n.t("user_tasks.proof_not_found")
      end
      @user_task = UserTask.find_by_user_and_task_id current_user, (params[:task_id] || params[:id])
      @task = @user_task.task if @user_task
      return record_not_found(message: message) unless @user_task
    end
end
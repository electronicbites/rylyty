class Api::V1::UserTasksController < Api::BaseController
  respond_to :json
  before_filter :authenticate_user!
  before_filter :require_user, except: [:like, :unlike]

  def index
    @user_tasks = @user.user_tasks
    render 'api/v1/user_tasks/task_index'
  end

  def like
    user = current_user
    task_user = User.find params[:user_id]
    user_task = UserTask.find_by_user_and_task_id task_user, params[:id]
    if user_task.present?
      l = Like.new(user_id: user.id, user_task_id: user_task.id)
      if l.valid?
        l.save
        user_task.create_news_feed_item(user_task.task, UserTask::EventTypes::LIKE, current_user)
        render json: {success: true}
      else
        render json: {success: false, message: l.errors.full_messages.join(',')}
      end
    else
      render json: {success: false, message: I18n.t('user_tasks.proof_not_found')}
    end
  end

  def unlike
    user = current_user
    begin task_user = User.find params[:user_id]
      user_task = UserTask.find_by_user_and_task_id task_user, params[:id]
      if user_task.present?
        l = Like.where(user_id: user.id, user_task_id: user_task.id).first
        if l.present?
          l.destroy
          render json: {success: true}
        else
          render json: {success: true, message: I18n.t('user_tasks.proof_not_liked')}
        end
      else
        render json: {success: true, message: I18n.t('user_tasks.proof_not_found')}
      end
    rescue ActiveRecord::RecordNotFound
      render json: {success: true, message: I18n.t('user_tasks.user_not_found')}
    end
  end
  
  def report
    @user_task = UserTask.find(params[:task_id])
    @user_task.approval_state = UserTask::ApprovalStates::REPORTED
    @user = current_user

    if @user_task.save
      @user_task.report current_user
      render 'api/v1/user_tasks/report'
    else
       render json:{ success: false, message: "something went wrong" }, status: 200
    end
  end

  def block
    @user_task = UserTask.find(params[:task_id])
    @user_task.block
    render :nothing => true
  end

  private

  def require_user
    @user ||= User.find(params[:user_id])
  end
end

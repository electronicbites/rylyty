object :@task => :task

extends '/api/v1/tasks/show_simple'

condition(->(task) { @playing_task = current_user.user_tasks.find_by_task_id(task.id) }) do
  node(:playing_task) { partial '/api/v1/user_tasks/show', object: @playing_task }
end

# This does _NOT_ reflect the current_user's UserTasks!
# but the Task.latest_advertised_answers:
node(:user_tasks) do |task|
  if defined?(@user_tasks) && !@user_tasks.empty?
    partial "/api/v1/user_tasks/index", object: @user_tasks
  else
    []
  end
end

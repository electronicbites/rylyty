object :@user_task => :user_task

attributes :id, :task_id, :user_id
node(:reporting_user) { @user.id }

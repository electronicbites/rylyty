module Workers
  module TimedTask
    
    # queue for resque
    @queue = :timed_tasks

    # callback for resque-worker
    def self.perform user_task_id
      user_task = UserTask.find user_task_id
      user_task.time_out!
    end
  end
end
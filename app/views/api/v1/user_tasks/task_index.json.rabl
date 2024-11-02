##
# List all user tasks into their original task information
#
collection :@user_tasks, root: 'tasks', object_root: false

# at the moment, rabl we cannot extend another 'collection' view and
# send another collection as object at the same time.
# so we just call the detail view directly, which seems to be more
# performant anyways
node(nil) { |user_task| partial "/api/v1/tasks/show_simple", object: user_task.task }

node :playing_task do |user_task|
  partial '/api/v1/user_tasks/show', object: user_task
end

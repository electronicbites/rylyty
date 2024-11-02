object :@task => :task

attributes :id, :title, :description, :short_description, :user_task_viewable

node(:time_limit) { |task| task.timeout_secs || 0}
node(:task_type)  { |task| task.type }
node(:thumb)      { |task| task.icon.url(:thumb) }
node(:thumb_hi)   { |task| task.icon.url(:thumb_hi) }
node(:position)   { |task| task.position }

# @todo `playable` is "not yet implemented"
#       In future tasks may only be played in order
node(:playable)   { |task| true }

node(nil, if: ->(task) { task.class < Task }) do |task|
  partial "/api/v1/tasks/tasks/#{task.class.to_s.underscore}", object: task
end
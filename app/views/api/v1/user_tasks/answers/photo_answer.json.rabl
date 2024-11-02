object :@user_task

node(:thumb)    { |user_task| user_task.photo.url(:thumb) }
node(:thumb_hi) { |user_task| user_task.photo.url(:thumb_hi) }
node(:big)      { |user_task| user_task.photo.url(:original) }

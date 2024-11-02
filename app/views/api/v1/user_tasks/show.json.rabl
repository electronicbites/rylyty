object :@user_task => :user_task

attributes :id, :user_id, :state, :verification_state

node(:proof_type)      { |user_task| user_task.type }
node(:proof_timestamp) { |user_task| user_task.finished_at.to_i if user_task.finished_at }
node(:game_id)         { |user_task| user_task.user_game.game_id }
node(:likes)           { |user_task| (@likes||=Like.likes_for_user_task(user_task)).size }
node(:liked)           { |user_task| @likes.find{|like| like.user.id == current_user.id}.present? }
node(:by_friend)       { |user_task| user_task.user.friends_with? current_user}

node(:comment, if: ->(user_task) {user_task.comment.present?}) do |user_task|
  user_task.comment
end

node(:reward, if: ->(user_task) { user_task.completed? }) do |user_task|
  user_task.reward
end

node(nil, if: ->(user_task) { user_task.class < UserTask }) do |user_task|
  partial "/api/v1/user_tasks/answers/#{user_task.class.to_s.underscore}", object: user_task
end

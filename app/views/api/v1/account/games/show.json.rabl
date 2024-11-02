##
# This renders the complete Game and Task information merged with the
# users's UserGame (playing_game) and UserTasks/*Answers (playing_task)

object :@user_game => :game

node(nil) { |user_game| partial "/api/v1/games/show_detail", object: user_game.game }

node :playing_game do |user_game|
  partial '/api/v1/account/games/user_game', object: user_game
end

node :tasks do |user_game|
  partial '/api/v1/user_tasks/task_index', object: user_game.user_tasks
end

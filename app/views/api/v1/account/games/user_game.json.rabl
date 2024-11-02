object :@user_game => :playing_game

attributes :game_id, :state
node(:started_at) { |user_game| user_game.started_at.to_i }
node(:finished_at) { |user_game| user_game.finished_at.to_i }
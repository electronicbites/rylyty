collection :@user_games, root: 'games', object_root: false

node(nil) { |user_game| partial "/api/v1/games/show_simple", object: user_game.game }

node :playing_game do |user_game|
  partial '/api/v1/account/games/user_game', :object => user_game
end

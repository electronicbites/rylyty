object :@game => :game

extends '/api/v1/games/show_detail'

condition(->(game) { @playing_game = current_user.user_games.find_by_game_id game.id }) do
  node(:playing_game) { partial 'api/v1/account/games/user_game', object: @playing_game }
end

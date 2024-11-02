collection :@games, root: 'suggestions', object_root: false

# this view meight be called with an emty collection,
# this uards us from trying ti access nil objects
node(nil, if: ->(g){g}) do |game|
  {
    suggestion: game.suggestion,
    game: partial("/api/v1/games/show_simple", object: game)
  }
end
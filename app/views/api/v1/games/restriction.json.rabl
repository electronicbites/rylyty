object :@game

node :restriction do |game|
  hsh = {}
  hsh[:points] = game.min_points_required if game.min_points_required.present? && game.min_points_required >= 1
  hsh[:badge]  = partial("/api/v1/badges/show", object: game.restriction_badge) if game.restriction_badge.present?
  hsh
end

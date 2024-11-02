object :@game => :game

node(:reward) do |game|
  hsh = {}
  hsh[:points] = game.total_reward_points if game.total_reward_points >= 1
  hsh[:badge] = partial("/api/v1/badges/show", object: game.reward_badge) if game.reward_badge.present?
  hsh
end
object :@game => :game

attributes :id, :title, :costs, :short_description, :minimum_age, :description

node(:min_points_required) { |game| game.min_points_required || 0 }
node(:time_limit)          { |game| game.time_limit || 0 }

node(:playable)            { |game| current_user.can_play game }
node(:my_game)             { |game| current_user.owns_game game }
node(:created_at)          { |game| game.created_at.to_i }
node(:tasks_count)         { |game| game.tasks_count }
node(:users_count)         { |game| game.users_count }

node(:icon)                { |game| game.icon_url }
node(:icon_hi)             { |game| game.icon_url_hi }
node(:thumb)               { |game| game.image.url(:thumb) }
node(:thumb_hi)            { |game| game.image.url(:thumb_hi) }
node(:normal)              { |game| game.image.url(:normal) }
node(:normal_hi)           { |game| game.image.url(:normal_hi) }
node(:normal_5)            { |game| game.image.url(:normal_5) }
node(:feed)                { |game| game.icon.url(:feed) }
node(:feed_hi)             { |game| game.icon.url(:feed_hi) }

node(:categories, if: ->(game) { game.categories.present? }) do |game|
  game.categories.map(&:value).join(',')
end

extends "/api/v1/games/reward"
extends "/api/v1/games/restriction"

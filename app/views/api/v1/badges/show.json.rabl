object :@badge => :badge
attributes :id, :title
node(:thumb) { |badge| badge.image.url(:thumb) }
node(:thumb_hi) { |badge| badge.image.url(:thumb_hi) }
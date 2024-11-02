object :@badge => :badge

attributes :id, :title, :description

node(:thumb)    { |badge| badge.image.url(:thumb) }
node(:thumb_hi) { |badge| badge.image.url(:thumb_hi) }

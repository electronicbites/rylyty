object :@game => :game

node(:recommended) { |game| (@recommended_index = (@recommended_games||[]).index(game)).present? }
node(:position, if: lambda{|game|@recommended_index.present?}) { |game| (@recommended_index + 1) }

module BadgeFinder

  CATEGORIES = [
    22, #Wissen
    4, #Hart am Limit
    5 #Um dich rum
  ]
  
  #find badges in category when a number of games is completed
  def self.category_badges user_game
    categories = user_game.game.categories.where('tags.id' => CATEGORIES).pluck('tags.id')
    user = user_game.user

    completed_user_games = []
    
    categories.each do |cat_id|
      completed_user_games = user.user_games.joins(:game, :game => :categories)
         .where( user_games: {state: 'completed'}, tags: {id: cat_id} )
         .group('user_games.id, tags.id')
      
      badge = Badge.where(
        "(context -> 'badge_type'=:type) AND (context -> 'game_category_id'=:cat_id) AND (context -> 'count' = :count)",
        { type: 'game_completed', cat_id: "#{cat_id}", count: "#{completed_user_games.length}"}
      ).first

      user.earn_user_badge badge unless badge.nil?
    end
  end

  def self.beta_invites invitation
    user = invitation.invited_by

    badge = Badge.where(
        "(context -> 'badge_type'=:type) AND (context -> 'count' = :count)",
        { type: 'beta_invite', count: Invitation.where(invited_by_id: user.id).count().to_s}
      ).first

    user.earn_user_badge badge unless badge.nil?
  end

  def self.early_bird user
    badge = Badge.where(
        "(context -> 'badge_type'=:type)",
        { type: 'early_bird'}
      ).first
    user.earn_user_badge badge unless badge.nil?
  end

end
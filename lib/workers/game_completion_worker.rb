# called via instrumentation/notification after a (user)game was completed. 
# handles all badges that were earned by the user for this game. (direct-game-reward but also other badge-contexts like 10-games-in-category)
class GameCompletionWorker
  
  def self.perform event_name, *args
    features = args.last
    case event_name
    when 'set_game_completion_badges'
      completed_user_game = features[:for]
      
      # add badge to user if game has reward-badge
      if completed_user_game.game.reward_badge.present?
        completed_user_game.user.earn_user_badge completed_user_game.game.reward_badge
        Rails.logger.debug "rewarded user #{completed_user_game.user.username} with badge #{completed_user_game.game.reward_badge.title}"
      end
      badges = BadgeFinder::category_badges completed_user_game
    end
  end

end

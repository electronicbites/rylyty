# this class is a temporary storage for category-badge mappings
class CategoryBadgeModel

  # attr_accessor :category, :num_games_completed_badge_context_map
  
  # def initialize category, num_games_completed_badge_context_map
  #   self.category = category
  #   self.num_games_completed_badge_context_map = num_games_completed_badge_context_map
  #   # save all contexts if not exist @see BadgeContext - context_for_name
  #   num_games_completed_badge_context_map.values.each{|badge_context|badge_context.save if badge_context.new_record?}
  # end
  
  # # maps a category to badge_contexts and the number of games that have to be played
  # # with the category to earn a badge
  # # the number of games is the suffix of the badge_context-(context-)name
  # CATEGORY_BADGE_MAPS = { 5 => # Um dich rum
  #                         [ 'category.curiosity_collector.3',
  #                           'category.curiosity_collector.10',
  #                           'category.curiosity_collector.30',
  #                           'category.curiosity_collector.50',
  #                           'category.curiosity_collector.70',
  #                           'category.curiosity_collector.100' ],
  #                         22 => # Wissen
  #                         [ 'category.superbrain.3',
  #                           'category.superbrain.10',
  #                           'category.superbrain.30',
  #                           'category.superbrain.50',
  #                           'category.superbrain.70',
  #                           'category.superbrain.100' ],
  #                         4 => # Hart am Limit
  #                         [ 'category.fearless.3',
  #                           'category.fearless.10',
  #                           'category.fearless.30',
  #                           'category.fearless.50',
  #                           'category.fearless.70',
  #                           'category.fearless.100' ]
  #                       }
  
  # def self.category_badge_models
  #     CATEGORY_BADGE_MAPS.collect do |category_id, bc_names|
  #      CategoryBadgeModel.new(Tag.find_by_id(category_id),
  #                                      Hash[*BadgeContext.context_for_name(bc_names, true).collect{|bc|[bc.name.match(/[0-9]+$/)[0].to_i, bc]}.flatten])
  #   end
  # end
  
end

class Tag  < ActiveRecord::Base
  GAME_CATEGORY_TYPE = 'GameCategory'

  attr_accessible :value, :context

  def self.tags_for_ids tag_ids
    return nil if tag_ids.nil?
    Tag.find_all_by_id tag_ids.keep_if {|t| !t.blank?}
  end
end

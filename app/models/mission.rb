class Mission < ActiveRecord::Base
  has_many :mission_games, :inverse_of => :mission
  has_many :games, through: :mission_games, source: :game
  has_many :tasks
  
  attr_accessible :start_points, :games
  
  def self.missions_for_ids mission_ids
    return nil if mission_ids.nil?
    missions = []
    mission_ids.each do |mission_id|
      next if mission_id.blank?
      missions << Mission.find(mission_id)
    end
    missions
  end
  
end

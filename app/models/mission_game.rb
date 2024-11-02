class MissionGame < ActiveRecord::Base
  belongs_to :mission
  belongs_to :game
  
  attr_accessible :mission, :game

  validates :mission, presence: true
  validates :game, presence: true
end

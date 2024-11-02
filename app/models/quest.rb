class Quest < ActiveRecord::Base
  attr_accessible :description

  validates :description, :presence => true

  def games 
    Game.where(:quest_id => id)
  end
end

class Badge < ActiveRecord::Base
    has_many :users
    has_many :user_badges
    
    attr_accessible :title, :description, :image, :context
     
    has_attached_file :image, :styles => { :thumb_hi => "300x260>", :thumb => "150x130>" },
      :path => ":rails_root/public/assets/badges/:id/:filename_:style"
  
    validates :title, presence: true

    def games id, type
      Game.where(type.to_sym => id)
    end
    
end

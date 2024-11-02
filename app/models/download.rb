class Download < ActiveRecord::Base

  belongs_to :download_link
  
  attr_accessible :download_link, :client_ip, :user_agent, :udid

  validates :download_link, presence: true 
  validates_each :download_link do |record, attr, value|
    case attr
    when :download_link
      record.errors.add(attr, 'download limit exceeded') if value.limit_reached?
    end
  end
  
  alias_attribute :downloaded_at, :created_at

end

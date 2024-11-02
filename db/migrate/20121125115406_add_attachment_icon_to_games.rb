class AddAttachmentIconToGames < ActiveRecord::Migration
  def self.up
    change_table :games do |t|
      t.has_attached_file :icon
    end
  end

  def self.down
    drop_attached_file :games, :icon
  end
end

class CreateBadges < ActiveRecord::Migration
  def change
    create_table :badges do |t|
      t.string :title
      t.text :description
      t.timestamps
    end
    create_table :obtained_badges do |t|
      t.integer :user_id
      t.integer :badge_id
      t.datetime :created_at, :null => false
      t.integer :badgeable_event_id
    end
    create_table :badgeable_events do |t|
      t.integer :badge_id
      t.references :event_source, :polymorphic => true
    end
    add_attachment :badges, :image
  end
end

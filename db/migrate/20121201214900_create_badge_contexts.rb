class CreateBadgeContexts < ActiveRecord::Migration
  def change
    create_table :badge_contexts do |t|
      t.datetime :created_at, nil: false
    end
  end
end

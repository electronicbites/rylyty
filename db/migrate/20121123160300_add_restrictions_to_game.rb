class AddRestrictionsToGame < ActiveRecord::Migration
  def change
     add_column :games, :restriction_points, :integer, null: false, default: 0
     add_column :badgeable_events, :context, :string
  end
end

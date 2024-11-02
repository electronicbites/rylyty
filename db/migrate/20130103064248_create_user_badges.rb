class CreateUserBadges < ActiveRecord::Migration
  def change
    create_table :user_badges do |t|
      t.references :user, :null => false
      t.references :badge, :null => false
      t.timestamps
    end
  end
end

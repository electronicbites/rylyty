class CreateQuests < ActiveRecord::Migration
  def change
    create_table :quests do |t|
      t.text :description

      t.timestamps
    end
  end
end

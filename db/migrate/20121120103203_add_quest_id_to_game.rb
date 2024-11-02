class AddQuestIdToGame < ActiveRecord::Migration
  def change
     add_column :games, :quest_id, :integer
  end
end

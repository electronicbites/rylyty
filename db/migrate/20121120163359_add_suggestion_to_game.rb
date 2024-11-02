class AddSuggestionToGame < ActiveRecord::Migration
  def change
    add_column :games, :suggestion, :text
  end
end

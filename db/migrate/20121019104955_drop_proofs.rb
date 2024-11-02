class DropProofs < ActiveRecord::Migration
  def up
    drop_table :proofs
  end

  def down
    create_table :proofs do |t|
      t.integer :task_id
      t.integer :user_game_id
      t.boolean :veryfied
      t.text :comment

      t.timestamps
    end
  end
end

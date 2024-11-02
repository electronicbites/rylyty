class AddPolymophicAssociationToFeedItem < ActiveRecord::Migration
  def change
    change_table :feed_items do |t|
      t.references :feedable, :polymorphic => true
    end
  end
end

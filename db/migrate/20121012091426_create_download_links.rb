class CreateDownloadLinks < ActiveRecord::Migration
  def change
    create_table :download_links do |t|
      t.string :url
      t.string :sha
      t.string :bundle
      t.integer :num_downloads
      
      t.datetime :created_at, nil: false
    end
    create_table :downloads do |t|
      t.integer :download_link_id

      t.datetime :created_at, nil: false
    end
  end
end

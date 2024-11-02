class AddSearchIndexToGames < ActiveRecord::Migration

  def up
    table_name = :games
    column_names = [:title, :short_description, :description]
    index_name = index_name(table_name, :column => column_names)
    index_columns = column_names * " || ' ' || "

    execute "CREATE INDEX #{quote_column_name(index_name)} ON #{quote_table_name(table_name)} USING gin(to_tsvector('german', #{index_columns}))"
  end

  def down
    table_name = :games
    column_names = [:title, :short_description, :description]
    index_name = index_name(table_name, :column => column_names)

    remove_index! :games, index_name
  end
end

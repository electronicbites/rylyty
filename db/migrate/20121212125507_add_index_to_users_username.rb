class AddIndexToUsersUsername < ActiveRecord::Migration
  def up
    table_name = :users
    column_names = [:username, :email]
    index_name = index_name(table_name, :column => column_names)
    execute "CREATE INDEX #{quote_column_name(index_name)} ON #{quote_table_name(table_name)} ((lower(username)), (lower(email)))"
  end

  def down
    table_name = :users
    column_names = [:username, :email]
    index_name = index_name(table_name, :column => column_names)
    remove_index! :games, index_name
  end
end

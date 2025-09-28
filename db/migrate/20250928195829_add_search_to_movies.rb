class AddSearchToMovies < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def up
    execute <<-SQL
      CREATE INDEX CONCURRENTLY movies_search_gin_idx 
      ON movies 
      USING GIN (to_tsvector('english', title || ' ' || COALESCE(description, '')));
    SQL

    add_index :movies, [:rating, :release_date], name: 'movies_rating_date_idx'
  end

  def down
    execute "DROP INDEX CONCURRENTLY IF EXISTS movies_search_gin_idx;"
    remove_index :movies, name: 'movies_rating_date_idx'
  end
end

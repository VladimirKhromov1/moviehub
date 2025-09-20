class CreateMovies < ActiveRecord::Migration[8.0]
  def change
    create_table :movies do |t|
      t.string :title, null: false
      t.text :description
      t.date :release_date
      t.string :poster_url
      t.integer :tmdb_id, null: false
      t.decimal :rating, precision: 3, scale: 1
      t.integer :likes_count, default: 0

      t.timestamps
    end

    add_index :movies, :tmdb_id, unique: true
    add_index :movies, :rating
    add_index :movies, :release_date
  end
end

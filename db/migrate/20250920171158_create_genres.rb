class CreateGenres < ActiveRecord::Migration[8.0]
  def change
    create_table :genres do |t|
      t.string :name, null: false
      t.integer :tmdb_id

      t.timestamps
    end

    add_index :genres, :name, unique: true
    add_index :genres, :tmdb_id, unique: true
  end
end

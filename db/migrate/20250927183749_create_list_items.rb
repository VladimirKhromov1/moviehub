class CreateListItems < ActiveRecord::Migration[8.0]
  def change
    create_table :list_items do |t|
      t.references :user_list, null: false, foreign_key: true
      t.references :movie, null: false, foreign_key: true
      t.timestamps
    end

    add_index :list_items, [:user_list_id, :movie_id], unique: true
  end
end

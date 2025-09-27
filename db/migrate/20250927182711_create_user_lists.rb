class CreateUserLists < ActiveRecord::Migration[8.0]
  def change
    create_table :user_lists do |t|
      t.string :name, null: false
      t.references :user, null: false, foreign_key: true
      t.timestamps
    end

    add_index :user_lists, [:user_id, :name], unique: true
  end
end

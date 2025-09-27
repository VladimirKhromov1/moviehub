# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_09_27_183749) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "genres", force: :cascade do |t|
    t.string "name", null: false
    t.integer "tmdb_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_genres_on_name", unique: true
    t.index ["tmdb_id"], name: "index_genres_on_tmdb_id", unique: true
  end

  create_table "likes", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "movie_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["movie_id"], name: "index_likes_on_movie_id"
    t.index ["user_id", "movie_id"], name: "index_likes_on_user_id_and_movie_id", unique: true
    t.index ["user_id"], name: "index_likes_on_user_id"
  end

  create_table "list_items", force: :cascade do |t|
    t.bigint "user_list_id", null: false
    t.bigint "movie_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["movie_id"], name: "index_list_items_on_movie_id"
    t.index ["user_list_id", "movie_id"], name: "index_list_items_on_user_list_id_and_movie_id", unique: true
    t.index ["user_list_id"], name: "index_list_items_on_user_list_id"
  end

  create_table "movie_genres", force: :cascade do |t|
    t.bigint "movie_id", null: false
    t.bigint "genre_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["genre_id"], name: "index_movie_genres_on_genre_id"
    t.index ["movie_id", "genre_id"], name: "index_movie_genres_on_movie_id_and_genre_id", unique: true
    t.index ["movie_id"], name: "index_movie_genres_on_movie_id"
  end

  create_table "movies", force: :cascade do |t|
    t.string "title", null: false
    t.text "description"
    t.date "release_date"
    t.string "poster_url"
    t.integer "tmdb_id", null: false
    t.decimal "rating", precision: 3, scale: 1
    t.integer "likes_count", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["rating"], name: "index_movies_on_rating"
    t.index ["release_date"], name: "index_movies_on_release_date"
    t.index ["tmdb_id"], name: "index_movies_on_tmdb_id", unique: true
  end

  create_table "user_lists", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "name"], name: "index_user_lists_on_user_id_and_name", unique: true
    t.index ["user_id"], name: "index_user_lists_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "likes", "movies"
  add_foreign_key "likes", "users"
  add_foreign_key "list_items", "movies"
  add_foreign_key "list_items", "user_lists"
  add_foreign_key "movie_genres", "genres"
  add_foreign_key "movie_genres", "movies"
  add_foreign_key "user_lists", "users"
end

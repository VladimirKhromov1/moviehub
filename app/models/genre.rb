class Genre < ApplicationRecord
  has_many :movie_genres, dependent: :destroy
  has_many :movies, through: :movie_genres

  validates :name, presence: true, uniqueness: true
  validates :tmdb_id, uniqueness: true, allow_nil: true
end
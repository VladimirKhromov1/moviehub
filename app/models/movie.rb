class Movie < ApplicationRecord
  has_many :movie_genres, dependent: :destroy
  has_many :genres, through: :movie_genres

  validates :title, presence: true
  validates :tmdb_id, presence: true, uniqueness: true
  validates :rating, presence: true, inclusion: { in: 0.0..10.0 }
end

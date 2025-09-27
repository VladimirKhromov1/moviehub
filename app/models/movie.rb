class Movie < ApplicationRecord
  has_many :movie_genres, dependent: :destroy
  has_many :genres, through: :movie_genres

  validates :title, presence: true
  validates :tmdb_id, presence: true, uniqueness: true
  validates :rating, presence: true, inclusion: { in: 0.0..10.0 }

  has_many :likes, dependent: :destroy
  has_many :liked_by_users, through: :likes, source: :user

  has_many :list_items, dependent: :destroy
  has_many :user_lists, through: :list_items

  scope :best_films, -> { where('likes_count > 0').order(likes_count: :desc) }
  scope :popular, -> { order(likes_count: :desc) }

  def liked_by?(user)
    return false unless user
    likes.exists?(user: user)
  end
end

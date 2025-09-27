class Like < ApplicationRecord
  belongs_to :user
  belongs_to :movie, counter_cache: true

  validates :movie_id, uniqueness: { scope: :user_id }
end
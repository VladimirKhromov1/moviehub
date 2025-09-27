class ListItem < ApplicationRecord
  belongs_to :user_list
  belongs_to :movie

  validates :movie_id, uniqueness: { scope: :user_list_id }
end
class UserList < ApplicationRecord
  belongs_to :user
  has_many :list_items, dependent: :destroy
  has_many :movies, through: :list_items

  validates :name, presence: true, uniqueness: { scope: :user_id }
  validates :name, length: { maximum: 100 }
end
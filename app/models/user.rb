class User < ApplicationRecord
  has_secure_password

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, presence: true, length: { minimum: 6 }, if: -> { new_record? || !password.nil? } #validates only if create or change password

  before_save { self.email = email.downcase }

  after_create :create_default_lists

  has_many :likes, dependent: :destroy
  has_many :liked_movies, through: :likes, source: :movie

  has_many :user_lists, dependent: :destroy

  DEFAULT_LISTS = {
    watchlist: 'Want to Watch',
    favorites: 'Favorites'
  }.freeze

  def liked?(movie)
    likes.exists?(movie: movie)
  end

  def watchlist
    user_lists.find_by(name: DEFAULT_LISTS[:watchlist])
  end

  def favorites
    user_lists.find_by(name: DEFAULT_LISTS[:favorites])
  end

  private

  def create_default_lists
    DEFAULT_LISTS.each_value do |list_name|
      user_lists.create!(name: list_name)
    end
  end
end

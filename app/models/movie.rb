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
  scope :with_genres_preloaded, -> { includes(:genres) }


  scope :search_by_query, ->(query) {
    return all if query.blank?

    sanitized = sanitize_sql_like(query.strip)
    where(
      "to_tsvector('english', title || ' ' || COALESCE(description, '')) @@ plainto_tsquery('english', ?)",
      sanitized
    ).or(
      where("title ILIKE ?", "%#{sanitized}%")
    )
  }

  scope :filter_by_genres, ->(genre_names) {
    return all if genre_names.blank?

    genres_array = Array(genre_names).reject(&:blank?)
    return all if genres_array.empty?

    joins(:genres)
      .where(genres: { name: genres_array })
      .distinct
  }

  scope :filter_by_min_rating, ->(min_rating) {
    return all if min_rating.blank?
    where('rating >= ?', min_rating.to_f)
  }

  scope :filter_by_year, ->(year) {
    return all if year.blank?
    where('EXTRACT(year FROM release_date) = ?', year.to_i)
  }

  scope :sort_by_criteria, ->(sort_by) {
    case sort_by.to_s.downcase
    when 'rating'
      order(rating: :desc, title: :asc)
    when 'year', 'release_date'
      order(release_date: :desc, title: :asc)
    when 'popularity', 'likes'
      order(likes_count: :desc, rating: :desc, title: :asc)
    when 'title', 'alphabetical'
      order(:title)
    else
      order(created_at: :desc, title: :asc)
    end
  }


  def liked_by?(user)
    return false unless user
    likes.exists?(user: user)
  end


  def self.search_and_filter(filters = {})
    with_genres_preloaded
      .search_by_query(filters[:search])
      .filter_by_genres(filters[:genres])
      .filter_by_min_rating(filters[:min_rating])
      .filter_by_year(filters[:year])
      .sort_by_criteria(filters[:sort_by])
  end

  def self.filter_stats
    {
      total_count: count,
      years: distinct.pluck(Arel.sql('EXTRACT(year FROM release_date)')).compact.sort.reverse,
      rating_ranges: group(Arel.sql('FLOOR(rating)')).count.transform_keys(&:to_i)
    }
  end
end
class Api::V1::MoviesController < Api::V1::BaseController
  before_action :set_movie, only: [:show]

  def index
    @movies = Movie.search_and_filter(search_params)
                   .page(current_page)
                   .per(per_page_limit)

    render json: {
      movies: @movies.map { |movie| movie_json(movie) },
      pagination: pagination_json(@movies),
      filters: active_filters_json
    }
  end

  def best_films
    @movies = Movie.best_films
                   .with_genres_preloaded
                   .page(current_page)
                   .per(per_page_limit)

    render json: {
      movies: @movies.map { |movie| movie_json(movie) },
      pagination: pagination_json(@movies)
    }
  end

  def show
    render json: movie_json(@movie)
  end

  def genres
    @genres = Genre.joins(:movies)
                   .select('genres.id, genres.name, COUNT(movies.id) as movies_count')
                   .group('genres.id, genres.name')
                   .order('genres.name')

    render json: {
      genres: @genres.map do |genre|
        {
          id: genre.id,
          name: genre.name,
          movies_count: genre.movies_count
        }
      end
    }
  end

  def filter_stats
    render json: Movie.filter_stats
  end

  private

  def set_movie
    @movie = Movie.find(params[:id])
  end

  def search_params
    params.permit(:search, :min_rating, :year, :sort_by).tap do |permitted|
      if params[:genres].present?
        genres = params[:genres].is_a?(String) ?
                   params[:genres].split(',').map(&:strip) :
                   Array(params[:genres])
        permitted[:genres] = genres.reject(&:blank?)
      end
    end
  end

  def current_page
    [params[:page].to_i, 1].max
  end

  def per_page_limit
    per_page = params[:per_page].to_i
    per_page = 20 if per_page <= 0
    [per_page, 100].min
  end

  def active_filters_json
    search_params.to_h.compact_blank
  end

  def movie_json(movie)
    {
      id: movie.id,
      title: movie.title,
      description: movie.description,
      release_date: movie.release_date,
      poster_url: movie.poster_url,
      rating: movie.rating,
      likes_count: movie.likes_count,
      genres: movie.genres.pluck(:name),
      created_at: movie.created_at,
      liked_by_current_user: current_user ? movie.liked_by?(current_user) : false
    }
  end

  def pagination_json(movies)
    {
      current_page: movies.current_page,
      total_pages: movies.total_pages,
      total_count: movies.total_count,
      per_page: movies.limit_value,
      has_next: !movies.last_page?,
      has_prev: !movies.first_page?
    }
  end
end
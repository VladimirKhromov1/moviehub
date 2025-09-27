class Api::V1::MoviesController < Api::V1::BaseController
  before_action :set_movie, only: [:show]

  def best_films
    page = params[:page]&.to_i || 1
    per_page = params[:per_page]&.to_i || 20
    per_page = [per_page, 100].min

    movies = Movie.best_films.includes(:genres)
                  .page(page)
                  .per(per_page)

    render json: {
      movies: movies.map { |movie| movie_json(movie) },
      pagination: pagination_json(movies)
    }
  end

  def index
    page = params[:page]&.to_i || 1
    per_page = params[:per_page]&.to_i || 20
    per_page = [per_page, 100].min

    movies = Movie.includes(:genres)
                  .order(created_at: :desc)
                  .page(page)
                  .per(per_page)

    render json: {
      movies: movies.map { |movie| movie_json(movie) },
      pagination: pagination_json(movies)
    }
  end

  def show
    render json: movie_json(@movie)
  end


  private

  def set_movie
    @movie = Movie.find(params[:id])
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
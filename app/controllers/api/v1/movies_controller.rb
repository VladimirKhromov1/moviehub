class Api::V1::MoviesController < ApplicationController
  before_action :set_movie, only: [:show]

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
      pagination: {
        current_page: movies.current_page,
        total_pages: movies.total_pages,
        total_count: movies.total_count,
        per_page: movies.limit_value,
        has_next: !movies.last_page?,
        has_prev: !movies.first_page?
      }
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
      created_at: movie.created_at
    }
  end
end
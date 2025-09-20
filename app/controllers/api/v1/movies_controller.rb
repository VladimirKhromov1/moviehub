class Api::V1::MoviesController < ApplicationController
  before_action :set_movie, only: [:show]

  def index
    movies = Movie.includes(:genres).order(created_at: :desc).limit(20)
    render json: movies.map { |movie| movie_json(movie) }
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
class Api::V1::LikesController < Api::V1::BaseController
  before_action :require_authentication
  before_action :set_movie

  def create
    like = current_user.likes.build(movie: @movie)

    if like.save
      render json: {
        message: 'Movie liked',
        likes_count: @movie.reload.likes_count,
        liked: true
      }
    else
      render json: { errors: like.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    like = current_user.likes.find_by(movie: @movie)

    if like&.destroy
      render json: {
        message: 'Like removed',
        likes_count: @movie.reload.likes_count,
        liked: false
      }
    else
      render json: { error: 'Like not found' }, status: :not_found
    end
  end

  private

  def set_movie
    @movie = Movie.find(params[:id])
  end
end
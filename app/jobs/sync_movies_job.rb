# frozen_string_literal: true

class SyncMoviesJob < ApplicationJob
  sidekiq_options retry: 3

  def perform(pages: 5)
    Rails.logger.info "Syncing movies from TMDB..."

    ActiveRecord::Base.transaction do
      sync_genres
      sync_movies(pages)
    end

    Rails.logger.info "Movie sync completed"
  rescue => e
    Rails.logger.error "Movie sync failed: #{e.message}"
    raise e
  end

  private

  def sync_genres
    TmdbService.genres['genres'].each do |genre_data|
      Genre.find_or_create_by!(tmdb_id: genre_data['id']) do |genre|
        genre.name = genre_data['name']
      end
    end
  end

  def sync_movies(pages)
    (1..pages).each do |page|
      movies_data = TmdbService.popular_movies(page: page)
      movies_data['results'].each do |movie_data|
        sync_movie(movie_data)
      end
    end
  end

  def sync_movie(movie_data)
    movie = Movie.find_or_initialize_by(tmdb_id: movie_data['id'])

    movie.assign_attributes(
      title: movie_data['title'],
      description: movie_data['overview'],
      release_date: parse_date(movie_data['release_date']),
      rating: movie_data['vote_average'],
      poster_url: TmdbService.poster_url(movie_data['poster_path'])
    )

    movie.save! if movie.changed?

    # Sync genres
    if movie_data['genre_ids'].present?
      movie.genres = Genre.where(tmdb_id: movie_data['genre_ids'])
    end
  end

  def parse_date(date_string)
    return nil if date_string.blank?
    Date.parse(date_string)
  rescue Date::Error
    nil
  end
end
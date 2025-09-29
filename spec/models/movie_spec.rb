# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Movie, type: :model do
  describe 'validations' do
    subject { build(:movie) }

    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:tmdb_id) }
    it { is_expected.to validate_uniqueness_of(:tmdb_id) }
    it { is_expected.to validate_presence_of(:rating) }
    it { is_expected.to validate_inclusion_of(:rating).in_range(0.0..10.0) }
  end

  describe 'associations' do
    it { is_expected.to have_many(:movie_genres).dependent(:destroy) }
    it { is_expected.to have_many(:genres).through(:movie_genres) }
    it { is_expected.to have_many(:likes).dependent(:destroy) }
    it { is_expected.to have_many(:liked_by_users).through(:likes).source(:user) }
    it { is_expected.to have_many(:list_items).dependent(:destroy) }
    it { is_expected.to have_many(:user_lists).through(:list_items) }
  end

  describe 'scopes' do
    describe '.best_films' do
      let!(:popular_movie) { create(:movie, likes_count: 10) }
      let!(:unpopular_movie) { create(:movie, likes_count: 0) }
      let!(:very_popular_movie) { create(:movie, likes_count: 20) }

      it 'returns movies with likes ordered by likes_count' do
        result = Movie.best_films
        expect(result).to eq([ very_popular_movie, popular_movie ])
        expect(result).not_to include(unpopular_movie)
      end
    end

    describe '.popular' do
      let!(:movie1) { create(:movie, likes_count: 5) }
      let!(:movie2) { create(:movie, likes_count: 10) }
      let!(:movie3) { create(:movie, likes_count: 1) }

      it 'orders movies by likes_count descending' do
        result = Movie.popular
        expect(result).to eq([ movie2, movie1, movie3 ])
      end
    end

    describe '.with_genres_preloaded' do
      it 'includes genres association' do
        movie = create(:movie, :with_genres)
        result = Movie.with_genres_preloaded.find(movie.id)
        expect(result.association(:genres)).to be_loaded
      end
    end

    describe '.search_by_query' do
      let!(:movie1) { create(:movie, title: 'The Matrix', description: 'A computer hacker learns reality') }
      let!(:movie2) { create(:movie, title: 'Inception', description: 'A thief who steals secrets') }
      let!(:movie3) { create(:movie, title: 'Avatar', description: 'A marine on an alien planet') }

      context 'with blank query' do
        it 'returns all movies' do
          expect(Movie.search_by_query('')).to match_array([ movie1, movie2, movie3 ])
        end
      end

      context 'with title search' do
        it 'finds movies by title' do
          result = Movie.search_by_query('Matrix')
          expect(result).to include(movie1)
          expect(result).not_to include(movie2, movie3)
        end
      end

      context 'with description search' do
        it 'finds movies by description' do
          result = Movie.search_by_query('computer')
          expect(result).to include(movie1)
          expect(result).not_to include(movie2, movie3)
        end
      end
    end

    describe '.filter_by_genres' do
      let!(:action_genre) { create(:genre, :action) }
      let!(:comedy_genre) { create(:genre, :comedy) }
      let!(:action_movie) { create(:movie, genres: [ action_genre ]) }
      let!(:comedy_movie) { create(:movie, genres: [ comedy_genre ]) }
      let!(:mixed_movie) { create(:movie, genres: [ action_genre, comedy_genre ]) }

      context 'with blank genres' do
        it 'returns all movies' do
          expect(Movie.filter_by_genres([])).to match_array([ action_movie, comedy_movie, mixed_movie ])
        end
      end

      context 'with single genre' do
        it 'filters movies by genre' do
          result = Movie.filter_by_genres([ 'Action' ])
          expect(result).to include(action_movie, mixed_movie)
          expect(result).not_to include(comedy_movie)
        end
      end

      context 'with multiple genres' do
        it 'filters movies by any of the genres' do
          result = Movie.filter_by_genres([ 'Action', 'Comedy' ])
          expect(result).to match_array([ action_movie, comedy_movie, mixed_movie ])
        end
      end
    end

    describe '.filter_by_min_rating' do
      let!(:low_rated) { create(:movie, rating: 3.5) }
      let!(:mid_rated) { create(:movie, rating: 7.0) }
      let!(:high_rated) { create(:movie, rating: 9.2) }

      context 'with blank min_rating' do
        it 'returns all movies' do
          expect(Movie.filter_by_min_rating('')).to match_array([ low_rated, mid_rated, high_rated ])
        end
      end

      context 'with min_rating filter' do
        it 'returns movies with rating >= min_rating' do
          result = Movie.filter_by_min_rating(7.0)
          expect(result).to include(mid_rated, high_rated)
          expect(result).not_to include(low_rated)
        end
      end
    end

    describe '.filter_by_year' do
      let!(:old_movie) { create(:movie, release_date: Date.new(2010, 1, 1)) }
      let!(:recent_movie) { create(:movie, release_date: Date.new(2023, 6, 15)) }
      let!(:current_movie) { create(:movie, release_date: Date.new(2024, 3, 20)) }

      context 'with blank year' do
        it 'returns all movies' do
          expect(Movie.filter_by_year('')).to match_array([ old_movie, recent_movie, current_movie ])
        end
      end

      context 'with year filter' do
        it 'returns movies from specified year' do
          result = Movie.filter_by_year(2023)
          expect(result).to include(recent_movie)
          expect(result).not_to include(old_movie, current_movie)
        end
      end
    end

    describe '.sort_by_criteria' do
      let!(:movie_a) { create(:movie, title: 'A Movie', rating: 8.0, release_date: Date.new(2023, 1, 1), likes_count: 10) }
      let!(:movie_b) { create(:movie, title: 'B Movie', rating: 9.0, release_date: Date.new(2022, 1, 1), likes_count: 5) }

      context 'with rating sort' do
        it 'sorts by rating descending, then title' do
          result = Movie.sort_by_criteria('rating')
          expect(result.first).to eq(movie_b)
        end
      end

      context 'with year sort' do
        it 'sorts by release_date descending, then title' do
          result = Movie.sort_by_criteria('year')
          expect(result.first).to eq(movie_a)
        end
      end

      context 'with popularity sort' do
        it 'sorts by likes_count descending, then rating, then title' do
          result = Movie.sort_by_criteria('popularity')
          expect(result.first).to eq(movie_a)
        end
      end

      context 'with title sort' do
        it 'sorts alphabetically by title' do
          result = Movie.sort_by_criteria('title')
          expect(result.first).to eq(movie_a)
        end
      end

      context 'with default sort' do
        it 'sorts by created_at descending, then title' do
          movie_b.touch # Make it more recent
          result = Movie.sort_by_criteria('')
          expect(result.first).to eq(movie_b)
        end
      end
    end
  end

  describe '#liked_by?' do
    let(:movie) { create(:movie) }
    let(:user) { create(:user) }

    context 'when user is nil' do
      it 'returns false' do
        expect(movie.liked_by?(nil)).to be false
      end
    end

    context 'when user has liked the movie' do
      before { create(:like, user: user, movie: movie) }

      it 'returns true' do
        expect(movie.liked_by?(user)).to be true
      end
    end

    context 'when user has not liked the movie' do
      it 'returns false' do
        expect(movie.liked_by?(user)).to be false
      end
    end
  end

  describe '.search_and_filter' do
    let!(:action_genre) { create(:genre, :action) }
    let!(:action_movie) { create(:movie, title: 'Action Hero', rating: 8.0, release_date: Date.new(2023, 1, 1), genres: [ action_genre ]) }
    let!(:other_movie) { create(:movie, title: 'Romance Story', rating: 6.0, release_date: Date.new(2022, 1, 1)) }

    it 'applies all filters and sorting' do
      filters = {
        search: 'Action',
        genres: [ 'Action' ],
        min_rating: 7.0,
        year: 2023,
        sort_by: 'rating'
      }

      result = Movie.search_and_filter(filters)
      expect(result).to include(action_movie)
      expect(result).not_to include(other_movie)
    end
  end

  describe '.filter_stats' do
    let!(:movie1) { create(:movie, rating: 8.5, release_date: Date.new(2023, 1, 1)) }
    let!(:movie2) { create(:movie, rating: 7.2, release_date: Date.new(2022, 1, 1)) }

    it 'returns filter statistics' do
      stats = Movie.filter_stats

      expect(stats[:total_count]).to eq(2)
      expect(stats[:years]).to include(2023, 2022)
      expect(stats[:rating_ranges]).to be_a(Hash)
    end
  end
end

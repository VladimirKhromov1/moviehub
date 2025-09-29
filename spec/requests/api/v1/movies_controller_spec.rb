# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::MoviesController', type: :request do
  let(:user) { create(:user) }
  let!(:action_genre) { create(:genre, :action) }
  let!(:comedy_genre) { create(:genre, :comedy) }
  let!(:movie1) { create(:movie, title: 'Action Hero', rating: 8.5, release_date: Date.new(2023, 1, 1), genres: [ action_genre ], likes_count: 10) }
  let!(:movie2) { create(:movie, title: 'Comedy Gold', rating: 7.2, release_date: Date.new(2022, 6, 15), genres: [ comedy_genre ], likes_count: 5) }

  describe 'GET /api/v1/movies' do
    context 'without authentication' do
      it 'returns movies list' do
        get '/api/v1/movies'

        expect(response).to have_http_status(:ok)
        expect(json_response[:movies]).to be_an(Array)
        expect(json_response[:movies].length).to eq(2)
      end

      it 'includes movie data without liked_by_current_user' do
        get '/api/v1/movies'

        movie_json = json_response[:movies].first
        expect(movie_json).to include(
          id: be_present,
          title: be_present,
          rating: be_present,
          liked_by_current_user: false
        )
      end
    end

    context 'with authentication' do
      before do
        set_auth_cookie_for(user)
        create(:like, user: user, movie: movie1)
      end

      it 'includes liked_by_current_user status' do
        get '/api/v1/movies'

        movie_data = json_response[:movies].find { |m| m[:id] == movie1.id }
        expect(movie_data[:liked_by_current_user]).to be true

        movie_data = json_response[:movies].find { |m| m[:id] == movie2.id }
        expect(movie_data[:liked_by_current_user]).to be false
      end
    end

    context 'with search parameters' do
      it 'filters by search query' do
        get '/api/v1/movies', params: { search: 'Action' }

        expect(response).to have_http_status(:ok)
        expect(json_response[:movies].length).to eq(1)
        expect(json_response[:movies].first[:title]).to eq('Action Hero')
      end

      it 'filters by genre' do
        get '/api/v1/movies', params: { genres: [ 'Action' ] }

        expect(response).to have_http_status(:ok)
        expect(json_response[:movies].length).to eq(1)
        expect(json_response[:movies].first[:genres]).to include('Action')
      end

      it 'filters by minimum rating' do
        get '/api/v1/movies', params: { min_rating: 8.0 }

        expect(response).to have_http_status(:ok)
        expect(json_response[:movies].length).to eq(1)
        expect(json_response[:movies].first[:rating].to_f).to be >= 8.0
      end

      it 'filters by year' do
        get '/api/v1/movies', params: { year: 2023 }

        expect(response).to have_http_status(:ok)
        expect(json_response[:movies].length).to eq(1)
        expect(json_response[:movies].first[:title]).to eq('Action Hero')
      end

      it 'sorts by rating' do
        get '/api/v1/movies', params: { sort_by: 'rating' }

        expect(response).to have_http_status(:ok)
        expect(json_response[:movies].first[:rating]).to be >= json_response[:movies].last[:rating]
      end
    end

    context 'with pagination' do
      it 'includes pagination data' do
        get '/api/v1/movies'

        expect(json_response[:pagination]).to include(
          current_page: 1,
          total_pages: be_present,
          total_count: be_present,
          per_page: be_present,
          has_next: be_in([ true, false ]),
          has_prev: false
        )
      end

      it 'handles page parameter' do
        get '/api/v1/movies', params: { page: 2 }

        expect(response).to have_http_status(:ok)
        expect(json_response[:pagination][:current_page]).to eq(2)
      end

      it 'handles per_page parameter' do
        get '/api/v1/movies', params: { per_page: 1 }

        expect(response).to have_http_status(:ok)
        expect(json_response[:movies].length).to eq(1)
        expect(json_response[:pagination][:per_page]).to eq(1)
      end

      it 'limits per_page to maximum' do
        get '/api/v1/movies', params: { per_page: 200 }

        expect(json_response[:pagination][:per_page]).to eq(100)
      end

      it 'defaults per_page when invalid' do
        get '/api/v1/movies', params: { per_page: 0 }

        expect(json_response[:pagination][:per_page]).to eq(20)
      end
    end

    it 'includes active filters' do
      get '/api/v1/movies', params: { search: 'test', min_rating: 7.0 }

      expect(json_response[:filters]).to include(
        search: 'test',
        min_rating: '7.0'
      )
    end
  end

  describe 'GET /api/v1/movies/best_films' do
    let!(:popular_movie) { create(:movie, likes_count: 20) }
    let!(:unpopular_movie) { create(:movie, likes_count: 0) }

    it 'returns only movies with likes' do
      get '/api/v1/movies/best_films'

      expect(response).to have_http_status(:ok)
      movie_ids = json_response[:movies].map { |m| m[:id] }
      expect(movie_ids).to include(popular_movie.id, movie1.id, movie2.id)
      expect(movie_ids).not_to include(unpopular_movie.id)
    end

    it 'orders by likes count descending' do
      get '/api/v1/movies/best_films'

      expect(response).to have_http_status(:ok)
      likes_counts = json_response[:movies].map { |m| m[:likes_count] }
      expect(likes_counts).to eq(likes_counts.sort.reverse)
    end

    it 'includes pagination' do
      get '/api/v1/movies/best_films'

      expect(json_response[:pagination]).to be_present
    end
  end

  describe 'GET /api/v1/movies/:id' do
    context 'when movie exists' do
      it 'returns movie data' do
        get "/api/v1/movies/#{movie1.id}"

        expect(response).to have_http_status(:ok)
        expect(json_response).to include(
          id: movie1.id,
          title: movie1.title,
          description: movie1.description,
          rating: movie1.rating.to_s,
          genres: [ 'Action' ]
        )
      end

      context 'with authentication' do
        before do
          set_auth_cookie_for(user)
          create(:like, user: user, movie: movie1)
        end

        it 'includes liked_by_current_user status' do
          get "/api/v1/movies/#{movie1.id}"

          expect(response).to have_http_status(:ok)
          expect(json_response[:liked_by_current_user]).to be true
        end
      end
    end

    context 'when movie does not exist' do
      it 'returns not found error' do
        get '/api/v1/movies/99999'

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'GET /api/v1/movies/genres' do
    before do
      # Create some movies to get genre counts
      create(:movie, genres: [ action_genre ])
      create(:movie, genres: [ action_genre ])
    end

    it 'returns genres with movie counts' do
      get '/api/v1/movies/genres'

      expect(response).to have_http_status(:ok)
      expect(json_response[:genres]).to be_an(Array)

      action_genre_data = json_response[:genres].find { |g| g[:name] == 'Action' }
      expect(action_genre_data).to include(
        id: action_genre.id,
        name: 'Action',
        movies_count: be_present
      )
    end

    it 'orders genres by name' do
      get '/api/v1/movies/genres'

      genre_names = json_response[:genres].map { |g| g[:name] }
      expect(genre_names).to eq(genre_names.sort)
    end

    it 'only includes genres that have movies' do
      orphaned_genre = create(:genre, name: 'Orphaned')

      get '/api/v1/movies/genres'

      genre_names = json_response[:genres].map { |g| g[:name] }
      expect(genre_names).not_to include('Orphaned')
    end
  end

  describe 'GET /api/v1/movies/filter_stats' do
    it 'returns filter statistics' do
      get '/api/v1/movies/filter_stats'

      expect(response).to have_http_status(:ok)
      expect(json_response).to include(
        total_count: be_present,
        years: be_an(Array),
        rating_ranges: be_a(Hash)
      )
    end

    it 'includes available years' do
      get '/api/v1/movies/filter_stats'

      expect(json_response[:years]).to include("2023.0", "2022.0")
    end

    it 'includes rating distribution' do
      get '/api/v1/movies/filter_stats'

      expect(json_response[:rating_ranges]).to be_a(Hash)
      expect(json_response[:rating_ranges].keys.map(&:to_s)).to all(match(/^\d+$/))
    end
  end

  describe 'private methods behavior' do
    describe 'current_page' do
      it 'defaults to 1 for invalid page' do
        get '/api/v1/movies', params: { page: 0 }
        expect(json_response[:pagination][:current_page]).to eq(1)

        get '/api/v1/movies', params: { page: -1 }
        expect(json_response[:pagination][:current_page]).to eq(1)
      end
    end

    describe 'genre parsing' do
      it 'handles comma-separated genres string' do
        get '/api/v1/movies', params: { genres: 'Action,Comedy' }

        expect(response).to have_http_status(:ok)
        # Should find movies with either genre
        expect(json_response[:movies].length).to eq(2)
      end

      it 'handles array of genres' do
        get '/api/v1/movies', params: { genres: [ 'Action', 'Comedy' ] }

        expect(response).to have_http_status(:ok)
        expect(json_response[:movies].length).to eq(2)
      end

      it 'filters out blank genres' do
        get '/api/v1/movies', params: { genres: [ 'Action', '', ' ', 'Comedy' ] }

        expect(response).to have_http_status(:ok)
        expect(json_response[:movies].length).to eq(2)
      end
    end
  end
end

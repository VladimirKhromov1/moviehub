# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TmdbService, type: :service do
  describe 'constants' do
    it 'has correct base URL' do
      expect(TmdbService::BASE_URL).to eq('https://api.themoviedb.org/3')
    end

    it 'has API key from credentials' do
      expect(TmdbService::API_KEY).to eq(Rails.application.credentials.tmdb_api_key)
    end
  end

  describe '.popular_movies' do
    context 'with default page' do
      before do
        stub_request(:get, 'https://api.themoviedb.org/3/movie/popular')
          .with(query: hash_including('api_key'))
          .to_return(
            status: 200,
            body: {
              results: [ { title: 'Test Movie', id: 123 } ],
              page: 1,
              total_pages: 10,
              total_results: 200
            }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it 'fetches popular movies from TMDB API' do
        response = TmdbService.popular_movies

        expect(response).to be_a(Hash)
        expect(response).to have_key('results')
        expect(response['results']).to be_an(Array)
        expect(response['results'].first).to have_key('title')
        expect(response['results'].first).to have_key('id')
      end

      it 'includes pagination information' do
        response = TmdbService.popular_movies

        expect(response).to have_key('page')
        expect(response).to have_key('total_pages')
        expect(response).to have_key('total_results')
      end
    end

    context 'with specific page' do
      before do
        stub_request(:get, 'https://api.themoviedb.org/3/movie/popular')
          .with(query: hash_including('api_key', 'page' => '2'))
          .to_return(
            status: 200,
            body: { results: [], page: 2 }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it 'fetches movies from specified page' do
        response = TmdbService.popular_movies(page: 2)

        expect(response).to be_a(Hash)
        expect(response['page']).to eq(2)
        expect(response['results']).to be_an(Array)
      end
    end

    context 'when API is unavailable' do
      before do
        stub_request(:get, 'https://api.themoviedb.org/3/movie/popular')
          .with(query: hash_including('api_key'))
          .to_return(status: 500, body: 'Internal Server Error')
      end

      it 'raises an error' do
        expect { TmdbService.popular_movies }.to raise_error('TMDB API Error')
      end
    end
  end

  describe '.genres' do
    before do
      stub_request(:get, 'https://api.themoviedb.org/3/genre/movie/list')
        .with(query: hash_including('api_key'))
        .to_return(
          status: 200,
          body: {
            genres: [ { id: 28, name: 'Action' }, { id: 35, name: 'Comedy' } ]
          }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
    end

    it 'fetches movie genres from TMDB API' do
      response = TmdbService.genres

      expect(response).to be_a(Hash)
      expect(response).to have_key('genres')
      expect(response['genres']).to be_an(Array)

      genre = response['genres'].first
      expect(genre).to have_key('id')
      expect(genre).to have_key('name')
    end

    context 'when API request fails' do
      before do
        stub_request(:get, 'https://api.themoviedb.org/3/genre/movie/list')
          .with(query: hash_including('api_key'))
          .to_return(status: 404, body: 'Not Found')
      end

      it 'raises an error' do
        expect { TmdbService.genres }.to raise_error('TMDB API Error')
      end
    end
  end

  describe '.poster_url' do
    context 'with valid poster path' do
      let(:poster_path) { '/example_poster.jpg' }

      it 'returns complete poster URL' do
        url = TmdbService.poster_url(poster_path)
        expect(url).to eq('https://image.tmdb.org/t/p/w500/example_poster.jpg')
      end
    end

    context 'with nil poster path' do
      it 'returns nil' do
        url = TmdbService.poster_url(nil)
        expect(url).to be_nil
      end
    end

    context 'with empty poster path' do
      it 'returns nil' do
        url = TmdbService.poster_url('')
        expect(url).to be_nil
      end
    end

    context 'with poster path that includes leading slash' do
      it 'handles double slashes correctly' do
        url = TmdbService.poster_url('/poster.jpg')
        expect(url).to eq('https://image.tmdb.org/t/p/w500/poster.jpg')
      end
    end
  end
end

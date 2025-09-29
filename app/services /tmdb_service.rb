# frozen_string_literal: true

class TmdbService
  BASE_URL = 'https://api.themoviedb.org/3'
  API_KEY = Rails.application.credentials.tmdb_api_key

  class << self
    def popular_movies(page: 1)
      request('movie/popular', page: page)
    end

    def genres
      request('genre/movie/list')
    end

    def poster_url(poster_path)
      "https://image.tmdb.org/t/p/w500#{poster_path}" if poster_path.present?
    end

    private

    def request(path, params = {})
      response = connection.get(path) do |req|
        req.params.update(params)
      end

      raise "TMDB API Error" unless response.success?
      JSON.parse(response.body)
    rescue Faraday::Error => e
      raise "TMDB API Error"
    end

    def connection
      @connection ||= Faraday.new(url: BASE_URL) do |faraday|
        faraday.params['api_key'] = API_KEY
        faraday.adapter Faraday.default_adapter
      end
    end
  end
end

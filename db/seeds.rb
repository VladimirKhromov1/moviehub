# Skip seeding in test environment
unless Rails.env.test?
  if Movie.count.zero? && Rails.application.credentials.tmdb_api_key.present?
    SyncMoviesJob.perform_now(pages: 10)
  end
end

# frozen_string_literal: true

namespace :movies do
  desc "Sync movies from TMDB now"
  task sync: :environment do
    SyncMoviesJob.perform_now
  end
end

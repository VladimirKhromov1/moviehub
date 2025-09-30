# frozen_string_literal: true

require 'sidekiq'
require 'sidekiq-cron'

Sidekiq.configure_server do |config|
  config.redis = { url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/0') }
  
  config.on(:startup) do
    Sidekiq::Cron::Job.create(
      name: 'Weekly Movie Sync',
      cron: '0 3 * * 1',
      class: 'SyncMoviesJob',
      args: [{ pages: 2 }]
    )
  end
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/0') }
end

# Sync initial data if database is empty
if Movie.count.zero?
  SyncMoviesJob.perform_now(pages: 10)
end

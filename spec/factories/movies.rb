# frozen_string_literal: true

FactoryBot.define do
  factory :movie do
    sequence(:title) { |n| "Movie Title #{n}" }
    description { "A compelling movie description that tells the story of heroes and villains." }
    release_date { Date.new(2020, 6, 15) }
    sequence(:tmdb_id) { |n| 1000 + n }
    rating { 7.5 }
    likes_count { 0 }
    poster_url { "https://image.tmdb.org/t/p/w500/example#{tmdb_id}.jpg" }

    trait :popular do
      likes_count { 100 }
    end

    trait :recent do
      release_date { Date.new(2023, 1, 1) }
    end

    trait :classic do
      release_date { Date.new(1980, 5, 25) }
    end

    trait :highly_rated do
      rating { 9.2 }
    end

    trait :with_genres do
      after(:create) do |movie|
        genres = create_list(:genre, 2)
        movie.genres = genres
      end
    end

    trait :with_likes do
      after(:create) do |movie|
        create_list(:like, 3, movie: movie)
        movie.update(likes_count: movie.likes.count)
      end
    end
  end
end

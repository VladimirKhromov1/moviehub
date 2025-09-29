# frozen_string_literal: true

FactoryBot.define do
  factory :genre do
    sequence(:name) { |n| [ "Action", "Comedy", "Drama", "Horror", "Sci-Fi", "Romance", "Thriller", "Adventure", "Fantasy", "Mystery" ][n % 10] || "Genre #{n}" }
    sequence(:tmdb_id) { |n| 10 + n }

    trait :action do
      name { "Action" }
      tmdb_id { 28 }
    end

    trait :comedy do
      name { "Comedy" }
      tmdb_id { 35 }
    end

    trait :drama do
      name { "Drama" }
      tmdb_id { 18 }
    end

    trait :with_movies do
      after(:create) do |genre|
        create_list(:movie, 3, genres: [ genre ])
      end
    end
  end
end

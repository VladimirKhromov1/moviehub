# frozen_string_literal: true

FactoryBot.define do
  factory :user_list do
    association :user
    sequence(:name) { |n| "My List #{n}" }

    trait :custom_watchlist do
      name { "Custom Watchlist" }
    end

    trait :custom_favorites do
      name { "Custom Favorites" }
    end

    trait :with_movies do
      after(:create) do |user_list|
        movies = create_list(:movie, 3)
        movies.each do |movie|
          create(:list_item, user_list: user_list, movie: movie)
        end
      end
    end
  end
end

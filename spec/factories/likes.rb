# frozen_string_literal: true

FactoryBot.define do
  factory :like do
    association :user
    association :movie

    trait :for_popular_movie do
      association :movie, :popular
    end
  end
end

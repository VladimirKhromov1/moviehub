# frozen_string_literal: true

FactoryBot.define do
  factory :movie_genre do
    association :movie
    association :genre
  end
end

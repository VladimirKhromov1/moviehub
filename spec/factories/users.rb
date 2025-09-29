# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { "password123" }
    password_confirmation { "password123" }

    trait :with_likes do
      after(:create) do |user|
        create_list(:like, 3, user: user)
      end
    end

    trait :with_lists do
      after(:create) do |user|
        create(:user_list, user: user, name: "Custom List")
      end
    end
  end
end

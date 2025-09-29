# frozen_string_literal: true

FactoryBot.define do
  factory :list_item do
    association :user_list
    association :movie
  end
end

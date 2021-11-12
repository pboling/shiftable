# frozen_string_literal: true

FactoryBot.define do
  factory :planet do
    name { Faker::Space.moon }
  end
end

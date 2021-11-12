# frozen_string_literal: true

FactoryBot.define do
  factory :space_station do
    name { Faker::Space.star }
  end
end

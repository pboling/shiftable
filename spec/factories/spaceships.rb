# frozen_string_literal: true

FactoryBot.define do
  factory :spaceship do
    name { Faker::Space.nasa_space_craft }
    power { rand(1_000...10_000) }
    captain
    space_federation
  end
end

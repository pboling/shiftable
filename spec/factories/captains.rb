# frozen_string_literal: true

FactoryBot.define do
  factory :captain do
    name { Faker::Games::SuperSmashBros.fighter }
    space_federation
  end
end

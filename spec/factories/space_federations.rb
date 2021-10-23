# frozen_string_literal: true

FactoryBot.define do
  factory :space_federation do
    name { Faker::TvShows::StarTrek.specie }
  end
end

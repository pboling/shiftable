# frozen_string_literal: true

FactoryBot.define do
  factory :space_treaty_signature do
    space_treaty
    trait :planet do
      signatory { create :planet }
    end
    trait :space_station do
      signatory { create :space_station }
    end
    trait :space_federation do
      signatory { create :space_federation }
    end
  end
end

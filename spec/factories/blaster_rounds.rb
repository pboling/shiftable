# frozen_string_literal: true

FactoryBot.define do
  factory :blaster_round do
    initialize_with { type.present? ? type.constantize.new : BlasterRound.new }
    type { "LaserBlasterRound" }

    name { Faker::Hipster.word }
    blaster
    space_federation

    trait :laser do
      type { "LaserBlasterRound" }
    end
    trait :laser_npc do
      type { "LaserBlasterNPCRound" }
    end
    trait :alien do
      type { "AlienBlasterRound" }
    end
    trait :alien_npc do
      type { "AlienBlasterNPCRound" }
    end
    trait :thunder do
      type { "ThunderBlasterRound" }
    end
    trait :big do
      type { "BigBlasterRound" }
    end
  end
end

# frozen_string_literal: true

FactoryBot.define do
  factory :blaster do
    initialize_with { type.present? ? type.constantize.new : Blaster.new }
    type { "LaserBlaster" }

    name { Faker::Hipster.word }
    captain

    trait :laser do
      type { "LaserBlaster" }
    end
    trait :laser_npc do
      type { "LaserBlasterNPC" }
    end
    trait :alien do
      type { "AlienBlaster" }
    end
    trait :alien_npc do
      type { "AlienBlasterNPC" }
    end
    trait :thunder do
      type { "ThunderBlaster" }
    end
    trait :big do
      type { "BigBlaster" }
    end
    trait :laser_npc_round_blaster do
      type { "LaserBlasterNPCRoundBlaster" }
    end
    trait :alien_npc_round_blaster do
      type { "AlienBlasterNPCRoundBlaster" }
    end
  end
end

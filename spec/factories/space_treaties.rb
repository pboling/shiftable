# frozen_string_literal: true

FactoryBot.define do
  factory :space_treaty do
    name { "#{Faker::Space.meteorite} Treaty" }

    trait :multivirate do
      transient do
        virates do
          {
            planet: 1,
            space_station: 1,
            space_federation: 1
          }
        end
      end

      after(:create) do |space_treaty, evaluator|
        np = evaluator.virates[:planet] || 0
        nss = evaluator.virates[:space_station] || 0
        nsf = evaluator.virates[:space_federation] || 0
        create_list(:space_treaty_signature, np, :planet, space_treaty: space_treaty) if np.positive?
        create_list(:space_treaty_signature, nss, :space_station, space_treaty: space_treaty) if nss.positive?
        create_list(:space_treaty_signature, nsf, :space_federation, space_treaty: space_treaty) if nsf.positive?
        space_treaty.reload
      end
    end
  end
end

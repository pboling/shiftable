# frozen_string_literal: true

RSpec.describe "factory definitions" do
  {
    blaster_round: [
      [],
      [:laser],
      [:laser_npc],
      [:alien],
      [:alien_npc],
      [:thunder],
      [:big]
    ],
    blaster: [
      [],
      [:laser],
      [:laser_npc],
      [:alien],
      [:alien_npc],
      [:thunder],
      [:big],
      [:laser_npc_round_blaster],
      [:alien_npc_round_blaster]
    ],
    captain: [[]],
    planet: [[]],
    space_federation: [[]],
    space_station: [[]],
    space_treaty: [
      [],
      [:multivirate],
      [:multivirate, { virates: { planet: 1 } }],
      [:multivirate, { virates: { planet: 2, space_station: 1 } }],
      [:multivirate, { virates: { planet: 1, space_station: 2, space_federation: 3 } }],
      [:multivirate, { virates: { space_station: 3 } }]
    ],
    space_treaty_signature: [
      [],
      [:planet],
      [:space_station],
      [:space_federation]
    ],
    spaceship: [[]]
  }.each do |factory_name, arg_sets|
    arg_sets.each do |args|
      describe "#{factory_name} with #{args}" do
        subject(:record) { create(factory_name, *args) }

        it "creates" do
          block_is_expected.not_to raise_error
        end
      end
    end
  end
end

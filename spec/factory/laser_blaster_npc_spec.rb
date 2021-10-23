# frozen_string_literal: true

RSpec.describe LaserBlasterNPC do
  subject(:factory) { %i[blaster laser_npc] }

  it_behaves_like "valid factory"
end

# frozen_string_literal: true

RSpec.describe AlienBlasterNPC do
  subject(:factory) { %i[blaster alien_npc] }

  it_behaves_like "valid factory"
end

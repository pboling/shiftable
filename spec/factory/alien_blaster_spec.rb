# frozen_string_literal: true

RSpec.describe AlienBlaster do
  subject(:factory) { %i[blaster alien] }
  it_behaves_like "valid factory"
end

# frozen_string_literal: true

RSpec.describe Spaceship do
  it_behaves_like "a shiftable single record", precheck: true do
    let(:factory) { :captain }
    let(:shift_to) { create :captain }
    let(:shift_from) { create :captain }
    let(:to_shift_blocker) { create :spaceship, captain: shift_to }
    let(:to_be_shifted) { create :spaceship, captain: shift_from }
  end
end

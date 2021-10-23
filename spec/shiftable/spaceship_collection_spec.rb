# frozen_string_literal: true

RSpec.describe Spaceship do
  it_behaves_like "a shiftable collection" do
    let(:factory) { :space_federation }
    let(:shift_to) { create :space_federation }
    let(:shift_from) { create :space_federation }
    let(:to_shift_blocker) { create :spaceship, space_federation: shift_to }
    let(:to_be_shifted) { create :spaceship, space_federation: shift_from }
  end
end

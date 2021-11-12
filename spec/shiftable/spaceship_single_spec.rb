# frozen_string_literal: true

RSpec.describe Spaceship do
  it_behaves_like "a shiftable single record", precheck: true do
    let(:factory) { :captain }
    let(:shift_to) { create :captain }
    let(:shift_from) { create :captain }
    let(:to_shift_blocker) { create :spaceship, captain: shift_to }
    let(:to_be_shifted) { create :spaceship, captain: shift_from }

    describe "wrapper" do
      subject(:shift_cx) { described_class.shift_single(shift_to: shift_to, shift_from: shift_from) }

      before { to_be_shifted }

      it "runs the each wrapper" do
        output = capture(:stdout) { shift_cx }
        log = "melon #{to_be_shifted.name} honey"
        expect(output).to include(log)
      end

      it "runs the all wrapper" do
        output = capture(:stdout) { shift_cx }
        log = "can you eat #{to_be_shifted.name} shoes"
        expect(output).to include(log)
      end
    end
  end
end

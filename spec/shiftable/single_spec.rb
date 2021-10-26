# frozen_string_literal: true

RSpec.describe Shiftable::Single do
  describe "invalid belongs_to" do
    subject(:bad_belongs_to_shift) do
      BadBlasterBTO.shooter_shift_single(shift_to: shift_to, shift_from: shift_from)
    end

    let(:shift_to) { create :captain }
    let(:shift_from) { create :captain }

    it "raises error" do
      block_is_expected.to raise_error(ArgumentError, "Unable to find belongs_to: :421 in BadBlasterBTO")
    end
  end

  describe "invalid has_one" do
    subject(:bad_belongs_to_shift) do
      BadBlasterHM.shooter_shift_single(shift_to: shift_to, shift_from: shift_from)
    end

    let(:shift_to) { create :captain }
    let(:shift_from) { create :captain }

    it "raises error" do
      block_is_expected.to raise_error(ArgumentError, "Unable to find belongs_to: :symbol in BadBlasterHM")
    end
  end

  describe "with side effects" do
    let(:factory) { :captain }
    let(:shift_to) { create :captain }
    let(:shift_from) { create :captain }
    let(:to_shift_blocker) { create :blaster, :big, captain: shift_to }
    let(:to_be_shifted) { create :blaster, :big, captain: shift_from }

    context "with before_shift" do
      subject(:shift_single_alt) do
        BigBlaster.shift_single(shift_to: shift_to, shift_from: shift_from)
        to_be_shifted.reload
      end

      it "increments ownership_changes" do
        block_is_expected.to change(to_be_shifted, :ownership_changes).by(1)
      end

      it "sets name" do
        block_is_expected.to change(to_be_shifted, :name).to("I-Got-Shifted-And-You-Should-Too")
      end
    end
  end
end

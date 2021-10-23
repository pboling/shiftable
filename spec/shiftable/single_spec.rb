# frozen_string_literal: true

RSpec.describe Shiftable::Single do
  describe "non-symbol belongs_to" do
    subject(:bad_belongs_to) do
      eval(<<-BAD
        class BadBlasterBTO < Blaster
          extend Shiftable::Single.new(belongs_to: 'string', has_one: :banana)
        end
      BAD
      )
    end
    it "raises ArgumentError" do
      block_is_expected.to raise_error(ArgumentError, "belongs_to must be a symbol")
    end
  end
  describe "non-symbol has_one" do
    subject(:bad_has_one) do
      eval(<<-BAD
        class BadBlasterHM < Blaster
          extend Shiftable::Single.new(belongs_to: :symbol, has_one: 42)
        end
      BAD
      )
    end
    it "raises ArgumentError" do
      block_is_expected.to raise_error(ArgumentError, "has_one must be a symbol")
    end
  end

  describe "with side effects" do
    let(:factory) { :captain }
    let(:shift_to) { create :captain }
    let(:shift_from) { create :captain }
    let(:to_shift_blocker) { create :blaster, :big, captain: shift_to }
    let(:to_be_shifted) { create :blaster, :big, captain: shift_from }

    context "with before_save" do
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

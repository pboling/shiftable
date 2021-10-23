# frozen_string_literal: true

RSpec.describe Shiftable::Single do
  describe "bad root class" do
    subject(:bad_root_class) do
      eval(<<-BAD
        class BadRootClass < Blaster
          extend Shiftable::Single.new(root_class: Integer, association: :banana)
        end
      BAD
          )
    end
    it "raises ArgumentError" do
      block_is_expected.to raise_error(ArgumentError, "root_class must respond_to :reflect_on_association")
    end
  end
  describe "bad association" do
    subject(:bad_root_class) do
      eval(<<-BAD
        class BadAssociation < Blaster
          extend Shiftable::Single.new(root_class: Captain, association: 42)
        end
      BAD
      )
    end
    it "raises ArgumentError" do
      block_is_expected.to raise_error(ArgumentError, "association must be a symbol")
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
        BigBlaster.shift_single(shift_to, shift_from)
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

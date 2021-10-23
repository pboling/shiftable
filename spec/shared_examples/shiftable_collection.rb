# frozen_string_literal: true

# Usage:
#
#   it_behaves_like "a shiftable collection" do
#     let(:shift_to) { create :space_federation }
#     let(:shift_from) { create :space_federation }
#     let(:to_be_shifted) { create :spaceship, captain: shift_from }
#   end
shared_examples_for "a shiftable collection" do
  describe "#shift_cx" do
    context "when shift_from is nil" do
      it "returns false" do
        result = described_class.shift_cx(shift_to: shift_to, shift_from: nil)
        expect(result).to be false
      end
    end

    context "when shift_from is new" do
      it "returns false" do
        result = described_class.shift_cx(shift_to: shift_to, shift_from: build(factory))
        expect(result).to be false
      end
    end

    context "when shift_from does not have one" do
      it "returns false" do
        result = described_class.shift_cx(shift_to: shift_to, shift_from: create(factory))
        expect(result).to be false
      end
    end

    context "when shift_from already has one" do
      context "when shift_to already has one" do
        it "returns the records" do
          to_be_shifted
          result = described_class.shift_cx(shift_to: shift_to, shift_from: shift_from)
          expect(result.map(&:id)).to eq([to_be_shifted.id])
        end

        it "moves existing record" do
          to_be_shifted
          described_class.shift_cx(shift_to: shift_to, shift_from: shift_from)
          expect(described_class.where(described_class.shift_cx_column => shift_to.id).pluck(:id)).to eq([to_be_shifted.id])
        end
      end

      context "when shift_to does not have one" do
        it "moves existing record shift_from => shift_to" do
          to_be_shifted
          described_class.shift_cx(shift_to: shift_to, shift_from: shift_from)
          expect(described_class.find_by(described_class.shift_cx_column => shift_to.id)).to be_a(described_class)
        end
      end
    end
  end
end

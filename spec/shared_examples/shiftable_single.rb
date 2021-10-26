# frozen_string_literal: true

# Usage:
#
#   it_behaves_like "a shiftable single record", preflight_checks: true do
#     let(:shift_to) { create :captain }
#     let(:shift_from) { create :captain }
#     let(:to_shift_blocker) { create :spaceship, captain: shift_to }
#     let(:to_be_shifted) { create :spaceship, captain: shift_from }
#   end
shared_examples_for "a shiftable single record" do |options|
  describe "#shift_single" do
    context "when shift_from is nil" do
      it "returns false" do
        result = described_class.shift_single(shift_to: shift_to, shift_from: nil)
        expect(result).to be false
      end
    end

    context "when shift_from is new" do
      it "returns false" do
        result = described_class.shift_single(shift_to: shift_to, shift_from: build(factory))
        expect(result).to be false
      end
    end

    context "when shift_from does not have one" do
      it "returns false" do
        result = described_class.shift_single(shift_to: shift_to, shift_from: create(factory))
        expect(result).to be false
      end
    end

    context "when shift_from already has one" do
      subject(:shift_single) { described_class.shift_single(shift_to: shift_to, shift_from: shift_from) }

      context "when shift_to already has one and preflight_checks: #{options[:preflight_checks]}" do
        if options[:preflight_checks]
          it "returns false" do
            to_be_shifted
            to_shift_blocker
            expect(shift_single).to be false
          end

          it "does not move (change) existing record" do
            to_shift_blocker
            expect(to_be_shifted.send(described_class.shift_column)).to eq(shift_from.id)
            described_class.shift_single(shift_to: shift_to, shift_from: shift_from)
            to_be_shifted.reload
            expect(to_be_shifted.send(described_class.shift_column)).to eq(shift_from.id)
          end
        else
          it "returns true" do
            to_be_shifted
            to_shift_blocker
            expect(shift_single).to be true
          end

          it "moves existing record" do
            to_shift_blocker
            expect(to_be_shifted.send(described_class.shift_column)).to eq(shift_from.id)
            described_class.shift_single(shift_to: shift_to, shift_from: shift_from)
            to_be_shifted.reload
            expect(to_be_shifted.send(described_class.shift_column)).to eq(shift_to.id)
          end
        end
      end

      context "when shift_to does not have one" do
        it "returns true" do
          to_be_shifted
          expect(shift_single).to be true
        end

        it "moves existing record" do
          expect(to_be_shifted.send(described_class.shift_column)).to eq(shift_from.id)
          described_class.shift_single(shift_to: shift_to, shift_from: shift_from)
          to_be_shifted.reload
          expect(to_be_shifted.send(described_class.shift_column)).to eq(shift_to.id)
        end
      end
    end
  end
end

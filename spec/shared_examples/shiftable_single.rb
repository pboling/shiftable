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
        result = described_class.shift_single(shift_to, nil)
        expect(result).to be false
      end
    end

    context "when shift_from is new" do
      it "returns false" do
        result = described_class.shift_single(shift_to, build(factory))
        expect(result).to be false
      end
    end

    context "when shift_from does not have one" do
      it "returns false" do
        result = described_class.shift_single(shift_to, create(factory))
        expect(result).to be false
      end
    end

    context "when shift_from already has one" do
      context "when shift_to already has one and preflight_checks: #{options[:preflight_checks]}" do
        if options[:preflight_checks]
          it "returns false" do
            to_be_shifted
            to_shift_blocker
            result = described_class.shift_single(shift_to, shift_from)
            expect(result).to be false
          end

          it "does not move existing record" do
            to_be_shifted
            to_shift_blocker
            described_class.shift_single(shift_to, shift_from)
            expect(described_class.where(described_class.shift_column => shift_to.id).pluck(:id)).to_not include(to_be_shifted.id)
          end
        else
          it "returns true" do
            to_be_shifted
            to_shift_blocker
            result = described_class.shift_single(shift_to, shift_from)
            expect(result).to be true
          end
          it "moves existing record" do
            to_be_shifted
            to_shift_blocker
            described_class.shift_single(shift_to, shift_from)
            expect(described_class.where(described_class.shift_column => shift_to.id).pluck(:id)).to include(to_be_shifted.id)
          end
        end
      end

      context "when shift_to does not have one" do
        it "moves existing record shift_from => shift_to" do
          to_be_shifted
          described_class.shift_single(shift_to, shift_from)
          expect(described_class.find_by(described_class.shift_column => shift_to.id)).to be_a(described_class)
        end
      end
    end
  end
end

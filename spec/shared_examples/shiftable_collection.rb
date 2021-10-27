# frozen_string_literal: true

# Usage:
#
#   it_behaves_like "a shiftable collection" do
#     let(:shift_to) { create :space_federation }
#     let(:shift_from) { create :space_federation }
#     let(:existing_record) { create :spaceship, captain: shift_to }
#     let(:to_be_shifted) { create :spaceship, captain: shift_from }
#   end
shared_examples_for "a shiftable collection" do
  describe "#shift_cx" do
    context "when shift_to is nil" do
      it "returns false" do
        expect do
          described_class.shift_cx(shift_to: nil,
                                   shift_from: shift_from)
        end.to raise_error(ArgumentError, "shift_to must have an id (primary key) value, but is: ")
      end
    end

    context "when shift_to is new" do
      it "returns false" do
        expect do
          described_class.shift_cx(shift_to: build(factory),
                                   shift_from: shift_from)
        end.to raise_error(ArgumentError, "shift_to must have an id (primary key) value, but is: ")
      end
    end

    context "when shift_from is nil" do
      it "returns false" do
        expect do
          described_class.shift_cx(shift_to: shift_to,
                                   shift_from: nil)
        end.to raise_error(ArgumentError, "shift_from must have an id (primary key) value, but is: ")
      end
    end

    context "when shift_from is new" do
      it "returns false" do
        expect do
          described_class.shift_cx(shift_to: shift_to,
                                   shift_from: build(factory))
        end.to raise_error(ArgumentError, "shift_from must have an id (primary key) value, but is: ")
      end
    end

    context "when shift_from does not have one" do
      it "returns false" do
        result = described_class.shift_cx(shift_to: shift_to, shift_from: create(factory))
        expect(result).to be false
      end
    end

    context "when shift_from already has one" do
      subject(:shift_cx) { described_class.shift_cx(shift_to: shift_to, shift_from: shift_from) }

      context "when shift_to already has one" do
        it "returns correct records" do
          to_be_shifted
          existing_record
          expect(shift_cx.map(&:id)).to eq([to_be_shifted.id])
        end

        it "returns correct type of records" do
          to_be_shifted
          expect(shift_cx.first).to be_a(described_class)
        end

        it "moves existing record" do
          to_be_shifted
          existing_record
          expect(described_class.where(described_class.shift_cx_column => shift_to.id).pluck(:id)).to eq([existing_record.id])
          shift_cx
          expect(described_class.where(described_class.shift_cx_column => shift_to.id).pluck(:id)).to eq([to_be_shifted.id,
                                                                                                          existing_record.id])
        end
      end

      context "when shift_to does not have one" do
        it "returns correct records" do
          to_be_shifted
          expect(shift_cx.map(&:id)).to eq([to_be_shifted.id])
        end

        it "returns correct type of records" do
          to_be_shifted
          expect(shift_cx.first).to be_a(described_class)
        end

        it "moves existing record" do
          to_be_shifted
          expect(described_class.where(described_class.shift_cx_column => shift_to.id).pluck(:id)).to eq([])
          shift_cx
          expect(described_class.where(described_class.shift_cx_column => shift_to.id).pluck(:id)).to eq([to_be_shifted.id])
        end
      end
    end
  end
end

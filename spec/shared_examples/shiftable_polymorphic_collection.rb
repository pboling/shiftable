# frozen_string_literal: true

# Usage:
#
#   it_behaves_like "is a shiftable polymorphic collection" do
#     let(:factory) { :space_federation }
#     let(:shift_to) { create :space_federation }
#     let(:shift_from) { create :space_federation }
#     let(:static_signatory) { create :planet }
#     let(:space_treaty) { create :space_treaty }
#     let(:existing_record) { create :space_treaty_signature, space_treaty: space_treaty, signatory: shift_to }
#     let(:to_be_shifted) { create :space_treaty_signature, space_treaty: space_treaty, signatory: shift_from }
#     let(:static_polymorph) { create :space_treaty_signature, space_treaty: space_treaty, signatory: static_signatory }
#     let(:method_prefix) { "space_federation_" }
#   end
shared_examples_for "is a shiftable polymorphic collection" do
  describe "#shift_pcx" do
    context "when shift_to is nil" do
      subject(:shift_pcx) { described_class.send(:"#{method_prefix}shift_pcx", shift_to: nil, shift_from: shift_from) }

      it "returns false" do
        block_is_expected.to raise_error(ArgumentError, "shift_to must have an id (primary key) value, but is: ")
      end
    end

    context "when shift_to is new" do
      subject(:shift_pcx) do
        described_class.send(:"#{method_prefix}shift_pcx", shift_to: build(factory), shift_from: shift_from)
      end

      it "returns false" do
        block_is_expected.to raise_error(ArgumentError, "shift_to must have an id (primary key) value, but is: ")
      end
    end

    context "when shift_from is nil" do
      subject(:shift_pcx) { described_class.send(:"#{method_prefix}shift_pcx", shift_to: shift_to, shift_from: nil) }

      it "returns false" do
        block_is_expected.to raise_error(ArgumentError, "shift_from must have an id (primary key) value, but is: ")
      end
    end

    context "when shift_from is new" do
      subject(:shift_pcx) do
        described_class.send(:"#{method_prefix}shift_pcx", shift_to: shift_to, shift_from: build(factory))
      end

      it "returns false" do
        block_is_expected.to raise_error(ArgumentError, "shift_from must have an id (primary key) value, but is: ")
      end
    end

    context "when shift_from does not have one" do
      it "returns false" do
        result = described_class.send(:"#{method_prefix}shift_pcx", shift_to: shift_to, shift_from: create(factory))
        expect(result).to be false
      end
    end

    context "when shift_from already has one" do
      subject(:shift_pcx) { described_class.send(:"#{method_prefix}shift_pcx", shift_to: shift_to, shift_from: shift_from) }

      context "when shift_to already has one" do
        it "returns correct records" do
          to_be_shifted
          existing_record
          expect(shift_pcx.map(&:id)).to eq([to_be_shifted.id])
        end

        it "returns correct type of records" do
          to_be_shifted
          expect(shift_pcx.first).to be_a(described_class)
        end

        it "moves existing record" do
          to_be_shifted
          existing_record
          expect(described_class.where(described_class.send(:"#{method_prefix}shift_pcx_column") => shift_to.id).pluck(:id)).to eq([existing_record.id])
          shift_pcx
          expect(described_class.where(described_class.send(:"#{method_prefix}shift_pcx_column") => shift_to.id).pluck(:id)).to eq([to_be_shifted.id,
                                                                                                                                    existing_record.id])
        end
      end

      context "when shift_to does not have one" do
        it "returns correct records" do
          to_be_shifted
          expect(shift_pcx.map(&:id)).to eq([to_be_shifted.id])
        end

        it "returns correct type of records" do
          to_be_shifted
          expect(shift_pcx.first).to be_a(described_class)
        end

        it "moves existing record" do
          to_be_shifted
          expect(described_class.where(described_class.send(:"#{method_prefix}shift_pcx_column") => shift_to.id).pluck(:id)).to eq([])
          shift_pcx
          expect(described_class.where(described_class.send(:"#{method_prefix}shift_pcx_column") => shift_to.id).pluck(:id)).to eq([to_be_shifted.id])
        end
      end
    end
  end
end

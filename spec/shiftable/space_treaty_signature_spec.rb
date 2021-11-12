# frozen_string_literal: true

RSpec.describe SpaceTreatySignature do
  describe "valid config" do
    subject(:shift_pcx) do
      described_class.space_federation_shift_pcx(shift_to: shift_to, shift_from: shift_from)
    end

    let(:shift_to) { create :space_federation }
    let(:shift_from) { create :space_federation }

    it "does not raise error" do
      block_is_expected.not_to raise_error
    end
  end

  it_behaves_like "is a shiftable polymorphic collection" do
    let(:factory) { :space_federation }
    let(:shift_to) { create :space_federation }
    let(:shift_from) { create :space_federation }
    let(:static_signatory) { create :planet }
    let(:space_treaty) { create :space_treaty }
    let(:existing_record) { create :space_treaty_signature, space_treaty: space_treaty, signatory: shift_to }
    let(:to_be_shifted) { create :space_treaty_signature, space_treaty: space_treaty, signatory: shift_from }
    let(:static_polymorph) { create :space_treaty_signature, space_treaty: space_treaty, signatory: static_signatory }
    let(:method_prefix) { "space_federation_" }
  end
end

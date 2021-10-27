# frozen_string_literal: true

RSpec.describe Shiftable::Collection do
  describe "invalid belongs_to" do
    subject(:bad_belongs_to_shift) do
      BadBlasterRoundBTO.shooter_shift_cx(shift_to: shift_to, shift_from: shift_from)
    end

    let(:shift_to) { create :space_federation }
    let(:shift_from) { create :space_federation }

    it "raises error" do
      block_is_expected.to raise_error(ArgumentError, "Unable to find belongs_to: :456 in BadBlasterRoundBTO")
    end
  end

  describe "invalid has_many" do
    subject(:bad_has_many_shift) do
      BadBlasterRoundHM.shooter_shift_cx(shift_to: shift_to, shift_from: shift_from)
    end

    let(:shift_to) { create :space_federation }
    let(:shift_from) { create :space_federation }

    it "raises error" do
      block_is_expected.to raise_error(ArgumentError, "Unable to find has_many: :444 in Blaster")
    end
  end

  describe "with prefix" do
    subject(:shift_cx) { BlasterRound.banana_shift_cx(shift_to: shift_to, shift_from: shift_from) }

    let(:factory) { :space_federation }
    let(:shift_to) { create :space_federation }
    let(:shift_from) { create :space_federation }
    let(:to_be_shifted) { BlasterRound.all }

    before do
      types = %i[laser alien thunder big]
      (0..3).each do |i|
        create :blaster_round, types[i], space_federation: shift_from
      end
    end

    it "shifts records" do
      block_is_expected.to change(to_be_shifted.where(space_federation: shift_to), :count).from(0).to(4)
    end
  end

  describe "with side effects" do
    let(:factory) { :space_federation }
    let(:shift_to) { create :space_federation }
    let(:shift_from) { create :space_federation }
    let(:to_be_shifted) { BigBlasterRound.all }

    before do
      types = %i[laser alien thunder]
      (0..3).each do |i|
        create :blaster_round, types[i], space_federation: shift_from
      end
      (0..3).each do |_i|
        create :blaster_round, :big, space_federation: shift_from
      end
    end

    context "with before_shift" do
      subject(:shift_cx_alt) do
        BigBlasterRound.shift_cx(shift_to: shift_to, shift_from: shift_from)
        to_be_shifted.reload
      end

      it "flips spent" do
        block_is_expected.to change { to_be_shifted.pluck(:spent).uniq }.from([false]).to([true])
      end

      it "sets name" do
        block_is_expected.to change { to_be_shifted.pluck(:name).sort }.
          to(%w[
               I-Got-Shifted-And-You-Should-Too-0
               I-Got-Shifted-And-You-Should-Too-1
               I-Got-Shifted-And-You-Should-Too-2
               I-Got-Shifted-And-You-Should-Too-3
             ])
      end

      it "sets space_federation_id" do
        block_is_expected.to change { to_be_shifted.pluck(:space_federation_id).uniq }.
          from([shift_from.id]).
          to([shift_to.id])
      end

      it "does not change LaserBlasterRounds" do
        block_is_expected.not_to change { LaserBlasterRound.all.pluck(:space_federation_id).uniq }.from([shift_from.id])
      end

      it "does not change AlienBlasterRounds" do
        block_is_expected.not_to change { AlienBlasterRound.all.pluck(:space_federation_id).uniq }.from([shift_from.id])
      end

      it "does not change ThunderBlasterRounds" do
        block_is_expected.not_to change {
          ThunderBlasterRound.all.pluck(:space_federation_id).uniq
        }.from([shift_from.id])
      end
    end
  end
end

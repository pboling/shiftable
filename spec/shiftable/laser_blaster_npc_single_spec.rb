# frozen_string_literal: true

RSpec.describe LaserBlasterNPC do
  let(:factory) { :captain }
  let(:shift_to) { create :captain }
  let(:shift_from) { create :captain }
  let(:to_shift_blocker) { create :blaster, :laser_npc, captain: shift_to }
  let(:to_be_shifted) { create :blaster, :laser_npc, captain: shift_from }

  it_behaves_like "a shiftable single record", preflight_checks: false

  describe "when different blasters exist" do
    context "with shift_to" do
      before do
        create :blaster, :thunder, captain: shift_to
      end

      it_behaves_like "a shiftable single record", preflight_checks: false
    end

    context "with shift_from" do
      before do
        create :blaster, :thunder, captain: shift_from
      end

      it_behaves_like "a shiftable single record", preflight_checks: false
      context "when also shift_to" do
        before do
          create :blaster, :thunder, captain: shift_to
          create :blaster, :thunder, captain: shift_from
        end

        it_behaves_like "a shiftable single record", preflight_checks: false
      end
    end
  end

  describe "when different STI blasters exist" do
    context "when shift_to" do
      before do
        create :blaster, :alien_npc, captain: shift_to
      end

      it_behaves_like "a shiftable single record", preflight_checks: false
    end

    context "when shift_from" do
      before do
        create :blaster, :alien_npc, captain: shift_from
      end

      it_behaves_like "a shiftable single record", preflight_checks: false
      context "when also shift_to" do
        before do
          create :blaster, :alien_npc, captain: shift_to
          create :blaster, :alien_npc, captain: shift_from
        end

        it_behaves_like "a shiftable single record", preflight_checks: false
      end
    end
  end
end

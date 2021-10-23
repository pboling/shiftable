# frozen_string_literal: true

RSpec.describe LaserBlaster do
  let(:factory) { :captain }
  let(:shift_to) { create :captain }
  let(:shift_from) { create :captain }
  let(:to_shift_blocker) { create :blaster, :laser, captain: shift_to }
  let(:to_be_shifted) { create :blaster, :laser, captain: shift_from }

  it_behaves_like "a shiftable single record", preflight_checks: true

  describe "when different blasters exist" do
    context "on shift_to" do
      before do
        create :blaster, :thunder, captain: shift_to
      end
      it_behaves_like "a shiftable single record", preflight_checks: true
    end
    context "on shift_from" do
      before do
        create :blaster, :thunder, captain: shift_from
      end
      it_behaves_like "a shiftable single record", preflight_checks: true
      context "and shift_to" do
        before do
          create :blaster, :thunder, captain: shift_to
          create :blaster, :thunder, captain: shift_from
        end
        it_behaves_like "a shiftable single record", preflight_checks: true
      end
    end
  end
  describe "when different STI blasters exist" do
    context "on shift_to" do
      before do
        create :blaster, :alien_npc, captain: shift_to
      end
      it_behaves_like "a shiftable single record", preflight_checks: true
    end
    context "on shift_from" do
      before do
        create :blaster, :alien_npc, captain: shift_from
      end
      it_behaves_like "a shiftable single record", preflight_checks: true
      context "and shift_to" do
        before do
          create :blaster, :alien_npc, captain: shift_to
          create :blaster, :alien_npc, captain: shift_from
        end
        it_behaves_like "a shiftable single record", preflight_checks: true
      end
    end
  end
end

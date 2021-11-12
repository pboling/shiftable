# frozen_string_literal: true

RSpec.describe AlienBlasterNPCRound do
  it_behaves_like "a shiftable collection" do
    let(:factory) { :blaster }
    let(:shift_to) { create :blaster, :alien_npc_round_blaster }
    let(:shift_from) { create :blaster, :alien_npc_round_blaster }
    let(:existing_record) { create :blaster_round, :alien_npc, alien_blaster_npc_round_blaster: shift_to }
    let(:to_be_shifted) { create :blaster_round, :alien_npc, alien_blaster_npc_round_blaster: shift_from }

    describe "wrapper" do
      subject(:shift_cx) { described_class.shift_cx(shift_to: shift_to, shift_from: shift_from) }

      before { to_be_shifted }

      it "runs the each wrapper" do
        output = capture(:stdout) { shift_cx }
        log = "hallo from #{to_be_shifted.name}"
        expect(output).to include(log)
      end
    end
  end
end

# frozen_string_literal: true

RSpec.describe LaserBlasterNPCRound do
  it_behaves_like "a shiftable collection" do
    let(:factory) { :blaster }
    let(:shift_to) { create :blaster, :laser_npc_round_blaster }
    let(:shift_from) { create :blaster, :laser_npc_round_blaster }
    let(:existing_record) { create :blaster_round, :laser_npc, laser_blaster_npc_round_blaster: shift_to }
    let(:to_be_shifted) { create :blaster_round, :laser_npc, laser_blaster_npc_round_blaster: shift_from }

    describe "wrapper" do
      subject(:shift_cx) { described_class.shift_cx(shift_to: shift_to, shift_from: shift_from) }

      before { to_be_shifted }

      it "runs the each wrapper" do
        output = capture(:stdout) { shift_cx }
        log = "berry #{to_be_shifted.name} carmel"
        expect(output).to include(log)
      end

      it "runs the all wrapper" do
        output = capture(:stdout) { shift_cx }
        log = "are there 1 snow cones"
        expect(output).to include(log)
      end
    end
  end
end

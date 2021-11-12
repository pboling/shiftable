# frozen_string_literal: true

# Class for testing
class BlasterRound < ActiveRecord::Base
  belongs_to :blaster
  belongs_to :space_federation
  extend Shiftable::Collection.new(
    belongs_to: :space_federation,
    has_many: :blaster_rounds,
    method_prefix: "banana_"
  )
end

# Class for testing
class LaserBlasterRound < BlasterRound
  extend Shiftable::Collection.new(belongs_to: :blaster, has_many: :laser_blaster_rounds)
end

# Class for testing
class LaserBlasterNPCRound < BlasterRound
  belongs_to :laser_blaster_npc_round_blaster, class_name: "LaserBlasterNPCRoundBlaster", foreign_key: :blaster_id
  include Activerecord::Transactionable
  extend Shiftable::Collection.new(
    belongs_to: :laser_blaster_npc_round_blaster,
    has_many: :laser_blaster_npc_rounds,
    wrapper: {
      each: lambda { |record, &block|
        record.transaction_wrapper(outside_rescued_errors: ActiveRecord::RecordNotUnique) do
          puts "berry #{record.name} carmel"
          block.call # does the actual saving!
        end
      },
      all: lambda { |shifting_rel, &block|
        LaserBlasterNPCRound.transaction_wrapper do
          puts "are there #{shifting_rel.count} snow cones"
          block.call
        end
      }
    }
  )
end

# Class for testing
class AlienBlasterRound < BlasterRound
  extend Shiftable::Collection.new(belongs_to: :blaster, has_many: :alien_blaster_rounds)
end

# Class for testing
class AlienBlasterNPCRound < BlasterRound
  belongs_to :alien_blaster_npc_round_blaster, class_name: "AlienBlasterNPCRoundBlaster", foreign_key: :blaster_id
  include Activerecord::Transactionable
  extend Shiftable::Collection.new(
    belongs_to: :alien_blaster_npc_round_blaster,
    has_many: :alien_blaster_npc_rounds,
    wrapper: {
      each: lambda { |record, &block|
        record.transaction_wrapper(outside_rescued_errors: ActiveRecord::RecordNotUnique) do
          puts "hallo from #{record.name}"
          block.call # does the actual saving!
        end
      }
    }
  )
end

# Test include instead of extend
class ThunderBlasterRound < BlasterRound
  class << self
    include Shiftable::Collection.new(belongs_to: :blaster, has_many: :thunder_blaster_rounds)
  end
end

# Test with before_shift
class BigBlasterRound < BlasterRound
  extend Shiftable::Collection.new(
    belongs_to: :space_federation,
    has_many: :big_blaster_rounds,
    before_shift: lambda do |shifting_rel|
      shifting_rel.each_with_index do |shifting, idx|
        shifting.spent = true
        shifting.name = "I-Got-Shifted-And-You-Should-Too-#{idx}"
      end
    end
  )
end

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
  extend Shiftable::Collection.new(belongs_to: :captain, has_many: :laser_blaster_rounds)
end

# Class for testing
class LaserBlasterNPCRound < BlasterRound
  extend Shiftable::Collection.new(belongs_to: :captain, has_many: :laser_blaster_rounds)
end

# Class for testing
class AlienBlasterRound < BlasterRound
  extend Shiftable::Collection.new(belongs_to: :captain, has_many: :alien_blaster_rounds)
end

# Class for testing
class AlienBlasterNPCRound < BlasterRound
  extend Shiftable::Collection.new(belongs_to: :captain, has_many: :alien_blaster_rounds)
end

# Test include instead of extend
class ThunderBlasterRound < BlasterRound
  class << self
    include Shiftable::Collection.new(belongs_to: :captain, has_many: :thunder_blaster_rounds)
  end
end

# Test with before_shift
class BigBlasterRound < BlasterRound
  extend Shiftable::Collection.new(
    belongs_to: :space_federation,
    has_many: :big_blaster_rounds,
    before_shift: lambda do |shifting_rel:, **_|
      shifting_rel.each_with_index do |shifting, idx|
        shifting.spent = true
        shifting.name = "I-Got-Shifted-And-You-Should-Too-#{idx}"
      end
    end
  )
end

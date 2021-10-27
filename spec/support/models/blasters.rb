# frozen_string_literal: true

# Class for testing
class Blaster < ActiveRecord::Base
  belongs_to :captain
  has_one :blaster_rounds
end

# Class for testing
class LaserBlaster < Blaster
  extend Shiftable::Single.new(belongs_to: :captain, has_one: :laser_blaster, precheck: true)
end

# Class for testing
class LaserBlasterNPC < Blaster
  extend Shiftable::Single.new(belongs_to: :captain, has_one: :laser_blaster, precheck: false)
end

# Class for testing
class AlienBlaster < Blaster
  extend Shiftable::Single.new(belongs_to: :captain, has_one: :alien_blaster, precheck: true)
end

# Class for testing
class AlienBlasterNPC < Blaster
  extend Shiftable::Single.new(belongs_to: :captain, has_one: :alien_blaster, precheck: false)
end

# Test include instead of extend
class ThunderBlaster < Blaster
  class << self
    include Shiftable::Single.new(belongs_to: :captain, has_one: :thunder_blaster)
  end
end

# Test with before_shift
class BigBlaster < Blaster
  extend Shiftable::Single.new(
    belongs_to: :captain,
    has_one: :big_blaster,
    before_shift: lambda do |shifting:, **_|
      shifting.ownership_changes += 1
      shifting.name = "I-Got-Shifted-And-You-Should-Too"
    end
  )
end

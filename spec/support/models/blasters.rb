# frozen_string_literal: true

class Blaster < ActiveRecord::Base
  belongs_to :captain
  has_one :blaster_rounds
end

class LaserBlaster < Blaster
  extend Shiftable::Single.new(belongs_to: :captain, has_one: :laser_blaster, preflight_checks: true)
end

class LaserBlasterNPC < Blaster
  extend Shiftable::Single.new(belongs_to: :captain, has_one: :laser_blaster, preflight_checks: false)
end

class AlienBlaster < Blaster
  extend Shiftable::Single.new(belongs_to: :captain, has_one: :alien_blaster, preflight_checks: true)
end

class AlienBlasterNPC < Blaster
  extend Shiftable::Single.new(belongs_to: :captain, has_one: :alien_blaster, preflight_checks: false)
end

# Test include instead of extend
class ThunderBlaster < Blaster
  class << self
    include Shiftable::Single.new(belongs_to: :captain, has_one: :thunder_blaster)
  end
end

# Test with before_save
class BigBlaster < Blaster
  extend Shiftable::Single.new(
    belongs_to: :captain,
    has_one: :big_blaster,
    before_save: lambda do |shifting:, **_|
      shifting.ownership_changes += 1
      shifting.name = "I-Got-Shifted-And-You-Should-Too"
    end
  )
end

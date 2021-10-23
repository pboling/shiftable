# frozen_string_literal: true

class Captain < ActiveRecord::Base
  # Test a regular has_one
  has_one :spaceship

  # Test single table inheritance has_one,
  has_one :laser_blaster, -> { where(type: "LaserBlaster") }, class_name: "LaserBlaster"
  #   and the interactions between multiple associations to the STI records
  has_one :alien_blaster, -> { where(type: "AlienBlaster") }, class_name: "AlienBlaster"

  # Test single table inheritance has_one, without any preflight checks
  has_one :laser_blaster_npc, -> { where(type: "LaserBlasterNPC") }, class_name: "LaserBlasterNPC"
  #   and the interactions between multiple associations to the STI records
  has_one :alien_blaster_npc, -> { where(type: "AlienBlasterNPC") }, class_name: "AlienBlasterNPC"

  # Test shifting with a yield
  has_one :thunder_blaster, -> { where(type: "ThunderBlaster") }, class_name: "ThunderBlaster"

  # Test shifting with a super
  has_one :big_blaster, -> { where(type: "BigBlaster") }, class_name: "BigBlaster"

  # Test a regular has_many
  has_many :blasters
end

class Blaster < ActiveRecord::Base
  belongs_to :captain
end

class LaserBlaster < Blaster
  extend Shiftable::Single.new(root_class: Captain, association: :laser_blaster, preflight_checks: true)
end

class LaserBlasterNPC < Blaster
  extend Shiftable::Single.new(root_class: Captain, association: :laser_blaster, preflight_checks: false)
end

class AlienBlaster < Blaster
  extend Shiftable::Single.new(root_class: Captain, association: :alien_blaster, preflight_checks: true)
end

class AlienBlasterNPC < Blaster
  extend Shiftable::Single.new(root_class: Captain, association: :alien_blaster, preflight_checks: false)
end

# Test include instead of extend
class ThunderBlaster < Blaster
  class << self
    include Shiftable::Single.new(root_class: Captain, association: :thunder_blaster)
  end
end

# Test with before_save
class BigBlaster < Blaster
  extend Shiftable::Single.new(
    root_class: Captain,
    association: :big_blaster,
    before_save: lambda do |to_shift, *_|
      to_shift.ownership_changes += 1
      to_shift.name = "I-Got-Shifted-And-You-Should-Too"
    end
  )
end

class Spaceship < ActiveRecord::Base
  belongs_to :captain
  extend Shiftable::Single.new(root_class: Captain, association: :spaceship)
end

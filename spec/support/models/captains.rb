# frozen_string_literal: true

# Class for testing
class Captain < ActiveRecord::Base
  extend Shiftable::Collection.new(belongs_to: :space_federation, has_many: :captains)

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

  # Test a multi-layered (cascading, even!) relationship
  belongs_to :space_federation
end

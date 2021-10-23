# frozen_string_literal: true

class SpaceFederation < ActiveRecord::Base
  has_many :captains
  has_many :spaceships

  # Test single table inheritance has_one,
  has_one :laser_blaster_rounds, -> { where(type: "LaserBlasterRound") }, class_name: "LaserBlasterRound"
  #   and the interactions between multiple associations to the STI records
  has_one :alien_blaster_rounds, -> { where(type: "AlienBlasterRound") }, class_name: "AlienBlasterRound"

  # Test single table inheritance has_one, without any preflight checks
  has_one :laser_blaster_npc_rounds, -> { where(type: "LaserBlasterNPCRound") }, class_name: "LaserBlasterNPCRound"
  #   and the interactions between multiple associations to the STI records
  has_one :alien_blaster_npc_rounds, -> { where(type: "AlienBlasterNPCRound") }, class_name: "AlienBlasterNPCRound"

  # Test shifting with a yield
  has_one :thunder_blaster_rounds, -> { where(type: "ThunderBlasterRound") }, class_name: "ThunderBlasterRound"

  # Test shifting with a super
  has_one :big_blaster_rounds, -> { where(type: "BigBlasterRound") }, class_name: "BigBlasterRound"

  has_many :blaster_rounds
end

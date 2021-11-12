# frozen_string_literal: true

# Class for testing
class SpaceStation < ActiveRecord::Base
  has_many :space_treaty_signature, as: :signatory
  has_many :space_treaties, through: :space_treaty_signatures
  has_many :treaty_federations, class_name: "SpaceFederation", through: :space_treaty_signatures, as: :signatory
  has_many :treaty_planets, class_name: "Planet", through: :space_treaty_signatures, as: :signatory
end

# frozen_string_literal: true

# Class for testing
class SpaceTreatySignature < ActiveRecord::Base
  belongs_to :space_treaty
  belongs_to :signatory, polymorphic: true
  extend Shiftable::Collection.new(
    belongs_to: :signatory, has_many: :space_treaty_signatures,
    polymorphic: { type: "SpaceFederation", as: :signatory },
    method_prefix: "space_federation_"
  )
end

# frozen_string_literal: true

# Class for testing
class Spaceship < ActiveRecord::Base
  extend Shiftable::Single.new(belongs_to: :captain, has_one: :spaceship)
  extend Shiftable::Collection.new(belongs_to: :space_federation, has_many: :spaceships)
  belongs_to :captain
  belongs_to :space_federation
end

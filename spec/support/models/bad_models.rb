# frozen_string_literal: true

# Class for testing
class BadBlasterRoundBTO < BlasterRound
  extend Shiftable::Collection.new(belongs_to: 456, has_many: :banana, method_prefix: "shooter_")
end

# Class for testing
class BadBlasterRoundHM < BlasterRound
  extend Shiftable::Collection.new(belongs_to: :blaster, has_many: 444, method_prefix: "shooter_")
end

# Class for testing
class BadBlasterBTO < Blaster
  extend Shiftable::Single.new(belongs_to: 421, has_one: :banana, method_prefix: "shooter_")
end

# Class for testing
class BadBlasterHM < Blaster
  extend Shiftable::Single.new(belongs_to: :captain, has_one: 401, method_prefix: "shooter_")
end

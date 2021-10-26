# frozen_string_literal: true

class BadBlasterRoundBTO < BlasterRound
  extend Shiftable::Collection.new(belongs_to: 456, has_many: :banana, method_prefix: "shooter_")
end

class BadBlasterRoundHM < BlasterRound
  extend Shiftable::Collection.new(belongs_to: :symbol, has_many: 444, method_prefix: "shooter_")
end

class BadBlasterBTO < Blaster
  extend Shiftable::Single.new(belongs_to: 421, has_one: :banana, method_prefix: "shooter_")
end

class BadBlasterHM < Blaster
  extend Shiftable::Single.new(belongs_to: :symbol, has_one: 401, method_prefix: "shooter_")
end

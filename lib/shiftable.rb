# frozen_string_literal: true

require_relative "shiftable/version"
require_relative "shiftable/shifting"
require_relative "shiftable/shifting_record"
require_relative "shiftable/shifting_relation"
require_relative "shiftable/mod_signature"
require_relative "shiftable/collection"
require_relative "shiftable/single"

module Shiftable
  class Error < StandardError; end
end

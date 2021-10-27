# frozen_string_literal: true

module Shiftable
  # Gets data to be shifted
  class Shifting
    attr_reader :to, :from, :column, :base, :result, :run_save

    def initialize(to:, from:, column:, base:)
      @to = to
      @from = from
      @column = column
      @base = base
      validate
      do_query = block_given? ? yield : true
      @result = do_query ? query : nil
      @run_save = true
    end

    # def found?
    #   raise "found? must be defined in a subclass"
    # end

    # def shift
    #   raise "shift must be defined in a subclass"
    # end

    private

    def validate
      raise ArgumentError, "shift_to must have an id (primary key) value, but is: #{to&.id}" unless to&.id
      raise ArgumentError, "shift_from must have an id (primary key) value, but is: #{from&.id}" unless from&.id
    end

    # def query
    #   raise "query must be defined in a subclass"
    # end
  end
end

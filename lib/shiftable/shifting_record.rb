# frozen_string_literal: true

module Shiftable
  # Gets data to be shifted
  class ShiftingRecord < Shifting
    def found?
      !!result
    end

    # @return true, false
    def shift
      return false unless found?

      result.send("#{column}=", to.id)
      @run_save = yield result if block_given?
      result.save if run_save
    end

    private

    def query
      base.find_by(column => from.id)
    end
  end
end

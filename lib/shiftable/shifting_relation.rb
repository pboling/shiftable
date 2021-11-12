# frozen_string_literal: true

module Shiftable
  # Gets data to be shifted
  class ShiftingRelation < Shifting
    include Enumerable

    def found?
      result.any?
    end

    def each(&block)
      result.each(&block)
    end

    # @return result (once it is shifted)
    def shift
      return false unless found?

      each do |record|
        record.send("#{column}=", to.id)
      end
      @run_save = yield if block_given?
      return result unless run_save

      run_save!
      result
    end

    private

    def query
      base.where(column => from.id)
    end
  end
end

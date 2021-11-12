# frozen_string_literal: true

module Shiftable
  # Gets data to be shifted
  class ShiftingPolymorphicRelation < Shifting
    include Enumerable

    def polymorphic_id_column
      column[:id_column]
    end

    def polymorphic_type_column
      "#{column[:as]}_type"
    end

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
        record.send("#{polymorphic_id_column}=", to.id)
      end
      @run_save = yield result if block_given?
      each(&:save) if run_save
      result
    end

    private

    def query
      base.where(
        polymorphic_type_column => column[:type],
        polymorphic_id_column => from.id
      )
    end
  end
end

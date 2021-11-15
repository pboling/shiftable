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
      @run_save = yield if block_given?
      return nil unless run_save

      run_save!
    end

    private

    def run_save!
      if shift_all_wrapper
        shift_all_wrapper.call(self) do
          do_save
        end
      else
        do_save
      end
    end

    def do_save
      if shift_each_wrapper
        shift_each_wrapper.call(result) do
          bang ? result.save! : result.save
        end
      else
        bang ? result.save! : result.save
      end
    end

    def query
      base.find_by(column => from.id)
    end
  end
end

# frozen_string_literal: true

module Shiftable
  # Gets data to be shifted
  class Shifting
    attr_reader :to, :from, :column, :base, :result, :run_save, :shift_all_wrapper, :shift_each_wrapper

    def initialize(to:, from:, column:, base:, wrapper:)
      @to = to
      @from = from
      @column = column
      @base = base
      validate
      do_query = block_given? ? yield : true
      @result = do_query ? query : nil
      @run_save = true
      @shift_all_wrapper = wrapper[:all]
      @shift_each_wrapper = wrapper[:each]
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

    def run_save!
      if shift_all_wrapper
        shift_all_wrapper.call(self) do
          do_saves
        end
      else
        do_saves
      end
    end

    def do_saves
      if shift_each_wrapper
        each do |rec|
          shift_each_wrapper.call(rec) do
            rec.save
          end
        end
      else
        each(&:save)
      end
    end

    # def query
    #   raise "query must be defined in a subclass"
    # end
  end
end

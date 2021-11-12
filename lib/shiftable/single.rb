# frozen_string_literal: true

# Targets classes that have:
#   1. belongs_to association with a shift_to Model, e.g. Spaceship belongs to Captain, and
#   2. the shift_to Model, e.g. Captain, has_one Spaceship record
# When the shift_to records (e.g. people) are merged,
#   these belongs_to/has_one associations must be carried over.
#
# Usage:
#
#   class Spaceship < ActiveRecord::Base
#     belongs_to :captain
#     extend Shiftable::Single.new(
#             belongs_to: :captain,
#             has_one: :spaceship,
#             precheck: true,
#             before_shift: ->(shifting:, shift_to:, shift_from:) { shifting.ownership_changes += 1 }
#           )
#   end
#
module Shiftable
  # Inheriting from Module is a powerful pattern. If you like it checkout the debug_logging gem!
  class Single < Module
    def initialize(belongs_to:, has_one:, method_prefix: nil, precheck: true, before_shift: nil)
      # Ruby's Module initializer doesn't take any arguments
      super()

      @signature = ModSignature.new(
        # For the following, imagine you are a Spaceship Captain, the Spaceship belongs_to you, and it has only one Captain.
        # But you have to sell it to your nemesis!
        associations: {
          # The name of the belongs_to association, defined on the shifting model, e.g. Spaceship
          # Normally a camel-cased, symbolized, version of the class name.
          # In the case where Spaceship belongs_to: :captain, this is :captain.
          belongs_to: belongs_to.to_s.to_sym,
          # The name of the has_one association, defined on the shift_to/shift_from model, e.g. Captain.
          # Normally a camel-cased, symbolized, version of the class name.
          # In the case where Captain has_one: :spaceship, this is :spaceship.
          has_one: has_one.to_s.to_sym
        },
        options: {
          # Do not move record if a record already exists (we are shifting a "has_one" association, after all)
          precheck: precheck,
          method_prefix: method_prefix,
          # will prevent the save if it returns false
          # allows for any custom logic to be run, such as setting attributes, prior to the shift (save).
          before_shift: before_shift
        },
        type: :sg
      )
    end

    # NOTE: Possible difference in how inheritance works when using extend vs include
    #       with Shiftable::Single.new
    def extended(base)
      shift_single_modulizer = ShiftSingleModulizer.to_mod(@signature.add_base(base))
      base.singleton_class.send(:prepend, shift_single_modulizer)
    end

    # NOTE: Possible difference in how inheritance works when using extend vs include
    #       with Shiftable::Single.new
    def included(base)
      shift_single_modulizer = ShiftSingleModulizer.to_mod(@signature.add_base(base))
      base.send(:prepend, shift_single_modulizer)
    end

    # Creates anonymous Ruby Modules, containing dynamically built methods
    module ShiftSingleModulizer
      def to_mod(signature)
        prefix = signature.method_prefix
        Module.new do
          define_method(:"#{prefix}shift_column") do
            signature.send("shift_#{signature.type}_column")
          end
          define_method(:"#{prefix}shift_single") do |shift_to:, shift_from:|
            signature.shift_data!(shift_to: shift_to, shift_from: shift_from)
          end
        end
      end

      module_function :to_mod
    end
  end
end

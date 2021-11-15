# frozen_string_literal: true

# Usage:
#
#   class BlasterRounds < ActiveRecord::Base
#     belongs_to :space_federation
#     extend Shiftable::Collection.new(
#             belongs_to: :space_federation,
#             has_many: :blaster_rounds,
#             method_prefix: "banana"
#           )
#   end
#
module Shiftable
  # Inheriting from Module is a powerful pattern. If you like it checkout the debug_logging gem!
  class Collection < Module
    # associations: belongs_to, has_many
    # options: method_prefix, before_shift
    def initialize(belongs_to:, has_many:, polymorphic: nil, method_prefix: nil, before_shift: nil, wrapper: nil)
      # Ruby's Module initializer doesn't take any arguments
      super()

      @signature = ModSignature.new(
        # For the following, imagine you are a Space Federation, each Spaceship in the fleet belongs_to you,
        #   i.e. the federation has_many spaceships.
        # But you lose the war, and your nemesis commandeers all your ships!
        associations: {
          # The name of the belongs_to association, defined on the shifting model, e.g. Spaceship
          # Normally a camel-cased, symbolized, version of the class name.
          # In the case where Spaceship belongs_to: :space_federation, this is :space_federation.
          belongs_to: belongs_to.to_s.to_sym,
          # The name of the has_many association, defined on the shift_to/shift_from model, e.g. SpaceFederation.
          # Normally a camel-cased, symbolized, version of the class name.
          # In the case where SpaceFederation has_many: :spaceships, this is :spaceships.
          has_many: has_many.to_s.to_sym
        },
        options: {
          polymorphic: polymorphic,
          method_prefix: method_prefix,
          # will prevent the save if it returns false
          # allows for any custom logic to be run, such as setting attributes, prior to the shift (save).
          before_shift: before_shift,
          # wrapper: {
          #   all: ->() { klass.transaction_wrapper { yield } },
          #   each: ->() { klass.transaction_wrapper { yield } },
          # }
          wrapper: wrapper
        },
        type: polymorphic ? :pcx : :cx
      )
    end

    # NOTE: Possible difference in how inheritance works when using extend vs include
    #       with Shiftable::Collection.new
    def extended(base)
      shift_cx_modulizer = ShiftCollectionModulizer.to_mod(@signature.add_base(base))
      base.singleton_class.send(:prepend, shift_cx_modulizer)
    end

    # NOTE: Possible difference in how inheritance works when using extend vs include
    #       with Shiftable::Collection.new
    def included(base)
      shift_cx_modulizer = ShiftCollectionModulizer.to_mod(@signature.add_base(base))
      base.send(:prepend, shift_cx_modulizer)
    end

    # Creates anonymous Ruby Modules, containing dynamically built methods
    module ShiftCollectionModulizer
      def to_mod(signature)
        prefix = signature.method_prefix
        type = signature.type
        Module.new do
          define_method(:"#{prefix}shift_#{type}_column") do
            signature.send("shift_#{type}_column")
          end
          define_method(:"#{prefix}shift_#{type}") do |shift_to:, shift_from:, bang: false|
            signature.shift_data!(shift_to: shift_to, shift_from: shift_from, bang: bang)
          end
        end
      end

      module_function :to_mod
    end
  end
end

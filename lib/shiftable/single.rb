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
#             preflight_checks: true,
#             before_shift: ->(shifting:, shift_to:, shift_from:) { shifting.ownership_changes += 1 }
#           )
#   end
#
module Shiftable
  # Inheriting from Module is a powerful pattern. If you like it checkout the debug_logging gem!
  class Single < Module
    def initialize(belongs_to:, has_one:, method_prefix: nil, preflight_checks: true, before_shift: nil)
      super()
      raise ArgumentError, "belongs_to must be a symbol" unless belongs_to.is_a?(Symbol)
      raise ArgumentError, "has_one must be a symbol" unless has_one.is_a?(Symbol)

      # For the following, imagine you are a Spaceship Captain, the Spaceship belongs_to you, and it has only one Captain.
      # But you have to sell it to your nemesis!
      #
      # The name of the belongs_to association, defined on the shifting model, e.g. Spaceship
      # Normally a camel-cased, symbolized, version of the class name.
      # In the case where Spaceship belongs_to: :captain, this is :captain.
      @belongs_to = belongs_to

      # The name of the has_one association, defined on the shift_to/shift_from model, e.g. Captain.
      # Normally a camel-cased, symbolized, version of the class name.
      # In the case where Captain has_one: :spaceship, this is :spaceship.
      @has_one = has_one

      @method_prefix = method_prefix

      # Do not move record if a record already exists (we are shifting a "has_one" association, after all)
      @preflight_checks = preflight_checks

      # will prevent the save if it returns false
      # allows for any custom logic to be run, such as setting shift_from attributes, prior to the shift is saved.
      @before_shift = before_shift
    end

    def extended(base)
      shift_single_modulizer = ShiftSingleModulizer.to_mod(@belongs_to, @has_one, @method_prefix, @preflight_checks,
                                                           @before_shift)
      base.singleton_class.send(:prepend, shift_single_modulizer)
    end

    def included(base)
      shift_single_modulizer = ShiftSingleModulizer.to_mod(@belongs_to, @has_one, @method_prefix, @preflight_checks,
                                                           @before_shift)
      base.send(:prepend, shift_single_modulizer)
    end

    # Creates anonymous Ruby Modules, containing dynamically built methods
    module ShiftSingleModulizer
      def to_mod(belongs_to, has_one, mepr, preflight_checks, before_shift)
        Module.new do
          define_method(:"#{mepr}shift_column") do
            reflection = reflect_on_association(belongs_to).klass.reflect_on_association(has_one)
            reflection.foreign_key
          end
          define_method(:"#{mepr}shift_find") do |id|
            return nil unless id

            find_by(send("#{mepr}shift_column") => id)
          end
          define_method(:"#{mepr}shift_safe_find") do |shift_to:, shift_from:|
            return false if shift_from&.id.nil?
            return false if shift_to&.id.nil?

            if preflight_checks
              already_exists = shift_to.send(has_one)
              return false if already_exists
            end

            send("#{mepr}shift_find", shift_from.id)
          end
          define_method(:"#{mepr}shift_single") do |shift_to:, shift_from:|
            shifting = send("#{mepr}shift_safe_find", shift_to: shift_to, shift_from: shift_from)
            return false unless shifting

            shifting.send("#{send("#{mepr}shift_column")}=", shift_to.id)
            shifting.save if before_shift.nil? || before_shift.call(shifting: shifting, shift_to: shift_to,
                                                                    shift_from: shift_from)
          end
        end
      end

      module_function :to_mod
    end
  end
end

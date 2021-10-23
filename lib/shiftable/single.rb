# frozen_string_literal: true

# Targets classes that have:
#   1. belongs_to association with a primary Model, e.g. Passport/Spaceship belongs to Citizen/Captain, and
#   2. the Primary Model, e.g. Citizen/Captain, has_one Passport/Spaceship record
# When the primary records (e.g. people) are merged,
#   these belongs_to/has_one associations must be carried over.
#
# Usage:
#
#     extend Shiftable::Single.new(
#             root_class: Citizen,
#             association: :passport,
#             preflight_checks: true,
#             before_shift: ->(to_shift, *_) { to_shift.ownership_changes += 1 }
#           )
#
module Shiftable
  # Inheriting from Module is a powerful pattern. If you like it checkout the debug_logging gem!
  class Single < Module
    def initialize(root_class:, association:, method_prefix: nil, preflight_checks: true, before_save: nil)
      super()
      unless root_class.respond_to?(:reflect_on_association)
        raise ArgumentError,
              "root_class must respond_to :reflect_on_association"
      end
      raise ArgumentError, "association must be a symbol" unless association.is_a?(Symbol)

      # The primary model, e.g. Citizen
      @root_class = root_class

      # The association name, defined on the primary model, e.g. Citizen/Captain, to the associated class.
      # Normally a camel-cased, symbolized, version of the class name.
      # In the case where Citizen/Captain has_one: :passport/:spaceship, this is :passport/:spaceship.
      @association = association

      @method_prefix = method_prefix

      # Do not move record if a record already exists (this is a has_one association, after all)
      @preflight_checks = preflight_checks

      # will prevent the save if it returns false
      # allows for any custom logic to be run, such as setting other attributes, prior to the shift is saved.
      @before_save = before_save
    end

    def extended(base)
      shift_single_modulizer = ShiftSingleModulizer.to_mod(@root_class, @association, @method_prefix, @preflight_checks,
                                                           @before_save)
      base.singleton_class.send(:prepend, shift_single_modulizer)
    end

    def included(base)
      shift_single_modulizer = ShiftSingleModulizer.to_mod(@root_class, @association, @method_prefix, @preflight_checks,
                                                           @before_save)
      base.send(:prepend, shift_single_modulizer)
    end

    # Creates anonymous Ruby Modules, containing dynamically built methods
    module ShiftSingleModulizer
      def to_mod(root_class, association, mepr, preflight_checks, before_save)
        Module.new do
          define_method(:"#{mepr}shift_column") do
            reflection = root_class.reflect_on_association(association)
            reflection.foreign_key
          end
          define_method(:"#{mepr}shift_find") do |id|
            return nil unless id

            find_by(send("#{mepr}shift_column") => id)
          end
          define_method(:"#{mepr}shift_safe_find") do |primary, other|
            return false if other&.id.nil?
            return false if primary&.id.nil?

            if preflight_checks
              already_exists = primary.send(association)
              return false if already_exists
            end

            send("#{mepr}shift_find", other.id)
          end
          define_method(:"#{mepr}shift_single") do |primary, other|
            to_shift = send("#{mepr}shift_safe_find", primary, other)
            return false unless to_shift

            to_shift.send("#{send("#{mepr}shift_column")}=", primary.id)
            to_shift.save if before_save.nil? || before_save.call(to_shift, primary, other)
          end
        end
      end

      module_function :to_mod
    end
  end
end

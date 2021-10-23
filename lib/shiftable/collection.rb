# frozen_string_literal: true

#
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
    def initialize(belongs_to:, has_many:, method_prefix: nil, preflight_checks: true, before_save: nil)
      super()
      raise ArgumentError, "belongs_to must be a symbol" unless belongs_to.is_a?(Symbol)
      raise ArgumentError, "has_many must be a symbol" unless has_many.is_a?(Symbol)

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
      @has_many = has_many

      @method_prefix = method_prefix

      # will prevent the save if it returns false
      # allows for any custom logic to be run, such as setting shift_from attributes, prior to the shift is saved.
      @before_save = before_save
    end

    def extended(base)
      shift_cx_modulizer = ShiftCollectionModulizer.to_mod(@belongs_to, @has_many, @method_prefix,
                                                           @before_save)
      base.singleton_class.send(:prepend, shift_cx_modulizer)
    end

    def included(base)
      shift_cx_modulizer = ShiftCollectionModulizer.to_mod(@belongs_to, @has_many, @method_prefix,
                                                           @before_save)
      base.send(:prepend, shift_cx_modulizer)
    end

    # Creates anonymous Ruby Modules, containing dynamically built methods
    module ShiftCollectionModulizer
      def to_mod(belongs_to, has_many, mepr, before_save)
        Module.new do
          define_method(:"#{mepr}shift_cx_column") do
            reflection = reflect_on_association(belongs_to).klass.reflect_on_association(has_many)
            reflection.foreign_key
          end
          define_method(:"#{mepr}shift_cx_relation") do |id|
            return nil unless id

            where(send("#{mepr}shift_cx_column") => id)
          end
          define_method(:"#{mepr}shift_cx_safe_relation") do |shift_to:, shift_from:|
            return false if shift_from&.id.nil?
            return false if shift_to&.id.nil?

            send("#{mepr}shift_cx_relation", shift_from.id)
          end
          define_method(:"#{mepr}shift_cx") do |shift_to:, shift_from:|
            shifting_rel = send("#{mepr}shift_cx_safe_relation", shift_to: shift_to, shift_from: shift_from)
            return false unless shifting_rel && shifting_rel.any?

            shifting_rel.each do |shifting|
              shifting.send("#{send("#{mepr}shift_cx_column")}=", shift_to.id)
            end
            before_save.call(shifting_rel: shifting_rel, shift_to: shift_to, shift_from: shift_from) if before_save
            shifting_rel.each do |shifting|
              shifting.save
            end
            shifting_rel
          end
        end
      end

      module_function :to_mod
    end
  end
end

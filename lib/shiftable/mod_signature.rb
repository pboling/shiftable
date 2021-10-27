# frozen_string_literal: true

module Shiftable
  class ModSignature
    VALID_TYPES = %i[sg cx].freeze
    VALID_ASSOCIATIONS = {
      sg: %i[belongs_to has_one],
      cx: %i[belongs_to has_many]
    }.freeze
    attr_accessor :associations, :options, :type
    attr_reader :base

    # Imagine you are a Spaceship Captain, the Spaceship belongs_to you, and it has only one Captain.
    # But you have to sell it to your nemesis!
    def initialize(associations:, type:, options: {})
      @associations = associations
      @options = options
      @type = type
      # See: https://maximomussini.com/posts/practical-applications-of-the-singleton-class/
      singleton_class.send(:prepend, Object.const_get("Shiftable::ModSignature::#{type.capitalize}Methods", false))
      validate
    end

    def validate
      raise ArgumentError, "type must be one of: #{VALID_TYPES}, provided: #{type}" unless VALID_TYPES.include?(type)
      raise ArgumentError, "associations must be symbols" if associations.keys.detect { |a| !a.is_a?(Symbol) }
      raise ArgumentError, "exactly two distinct associations must be provided" unless associations.keys.uniq.length == 2

      invalid_tokens = associations.keys - VALID_ASSOCIATIONS[type]
      raise ArgumentError, "valid associations: #{VALID_ASSOCIATIONS[type]}, invalid: #{invalid_tokens}" if invalid_tokens.any?
    end

    # @note Chainable
    # @return self
    def add_base(base)
      @base = base
      self
    end

    def has_rel_name
      VALID_ASSOCIATIONS[type][1]
    end

    def validate_relationships
      bt = base.reflect_on_association(belongs_to)
      raise ArgumentError, "Unable to find belongs_to: :#{belongs_to} in #{base}" unless bt

      hr = bt.klass.reflect_on_association(has_rel)
      raise ArgumentError, "Unable to find #{has_rel_name}: :#{has_rel} in #{bt.klass}" unless hr
    end

    module CxMethods
      def has_many
        associations[:has_many]
      end

      alias has_rel has_many

      # returns nil or ActiveRecord::Relation object
      def data_for_shift(id)
        base.where(send("shift_column") => id) if super
      end

      # returns false, nil or ActiveRecord::Relation object
      def data_for_shift_safe(shift_to:, shift_from:)
        return false unless super

        data_for_shift(shift_from.id)
      end

      def shift_data!(shift_to:, shift_from:)
        validate_relationships

        shifting_rel = data_for_shift_safe(shift_to: shift_to, shift_from: shift_from)
        return false unless shifting_rel && shifting_rel.any?

        shifting_rel.each do |shifting|
          shifting.send("#{send(:shift_column)}=", shift_to.id)
        end
        before_shift&.call(shifting_rel: shifting_rel, shift_to: shift_to, shift_from: shift_from)
        shifting_rel.each(&:save)
        shifting_rel
      end
    end

    module SgMethods
      def has_one
        associations[:has_one]
      end

      alias has_rel has_one

      # Do not move record if a record already exists (we are shifting a "has_one" association, after all)
      def preflight_checks
        options[:preflight_checks]
      end

      # returns nil or ActiveRecord object
      def data_for_shift(id)
        base.find_by(send("shift_column") => id) if super
      end

      # returns false, nil or ActiveRecord object
      def data_for_shift_safe(shift_to:, shift_from:)
        return false unless super

        if preflight_checks
          already_exists = shift_to.send(has_one)
          return false if already_exists
        end
        data_for_shift(shift_from.id)
      end

      def shift_data!(shift_to:, shift_from:)
        validate_relationships

        shifting = data_for_shift_safe(shift_to: shift_to, shift_from: shift_from)
        return false unless shifting

        shifting.send("#{send(:shift_column)}=", shift_to.id)
        shifting.save if before_shift.nil? || before_shift.call(shifting: shifting, shift_to: shift_to,
                                                                shift_from: shift_from)
      end
    end

    # The name of the belongs_to association, defined on the shifting model, e.g. Spaceship
    # Normally a camel-cased, symbolized, version of the class name.
    # In the case where Spaceship belongs_to: :captain, this is :captain.
    def belongs_to
      associations[:belongs_to]
    end

    def method_prefix
      options[:method_prefix]
    end

    # will prevent the save if it returns false
    # allows for any custom logic to be run, such as setting shift_from attributes, prior to the shift is saved.
    def before_shift
      options[:before_shift]
    end

    def shift_column
      reflection = base.reflect_on_association(belongs_to).klass.reflect_on_association(has_rel)
      reflection.foreign_key
    end

    # Effect is to short-circuit data_for_shift method prior to executing the ActiveRecord query
    #   if there is no ID, to avoid a full table scan when no id provided,
    #   e.g. where(id: nil).
    def data_for_shift(id)
      true if id
    end

    # Effect is to short-circuit data_for_shift_safe method prior to executing the ActiveRecord query
    #   if there is no ID, to avoid a full table scan when no id provided,
    #   e.g. where(id: nil).
    def data_for_shift_safe(shift_to:, shift_from:)
      true if shift_from&.id && shift_to&.id
    end
  end
end

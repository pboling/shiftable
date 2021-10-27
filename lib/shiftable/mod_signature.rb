# frozen_string_literal: true

module Shiftable
  class ModSignature
    VALID_TYPES = %i[sg cx].freeze
    VALID_ASSOCIATIONS = { sg: %i[belongs_to has_one], cx: %i[belongs_to has_many] }.freeze
    DEFAULT_BEFORE_SHIFT = ->(*_) { true }
    attr_reader :associations, :options, :type, :base

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
      raise ArgumentError, "type must be one of: #{VALID_TYPES}, provided: #{type}" if invalid_type?
      raise ArgumentError, "associations must be symbols" if invalid_association_key_type?
      raise ArgumentError, "exactly two distinct associations must be provided" if invalid_number_of_associations?
    end

    def invalid_type?
      !VALID_TYPES.include?(type)
    end

    def invalid_association_key_type?
      associations.keys.detect { |key| !key.is_a?(Symbol) }
    end

    def invalid_number_of_associations?
      associations.keys.uniq.length != 2
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

      klass = bt.klass
      hr = klass.reflect_on_association(has_rel)
      raise ArgumentError, "Unable to find #{has_rel_name}: :#{has_rel} in #{klass}" unless hr
    end

    module CxMethods
      def has_many
        associations[:has_many]
      end

      alias has_rel has_many

      def shift_data!(shift_to:, shift_from:)
        validate_relationships
        shifting_rel = ShiftingRelation.new(
          to: shift_to,
          from: shift_from,
          column: shift_column,
          base: base
        )
        shifting_rel.shift do |result|
          before_shift&.call(shifting_rel: result, shift_to: shift_to, shift_from: shift_from)
        end
      end
    end

    module SgMethods
      def has_one
        associations[:has_one]
      end

      alias has_rel has_one

      # Do not move record if a record already exists (we are shifting a "has_one" association, after all)
      def precheck
        options[:precheck]
      end

      def shift_data!(shift_to:, shift_from:)
        validate_relationships
        shifting = ShiftingRecord.new(
          to: shift_to,
          from: shift_from,
          column: shift_column,
          base: base
        ) do
          !precheck || !shift_to.send(has_one)
        end
        shifting.shift do |result|
          before_shift&.call(shifting: result, shift_to: shift_to, shift_from: shift_from)
        end
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
      options[:before_shift] || DEFAULT_BEFORE_SHIFT
    end

    def shift_column
      reflection = base.reflect_on_association(belongs_to).klass.reflect_on_association(has_rel)
      reflection.foreign_key
    end
  end
end

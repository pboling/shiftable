# frozen_string_literal: true

# Class for testing
class Spaceship < ActiveRecord::Base
  include Activerecord::Transactionable
  extend Shiftable::Single.new(
    belongs_to: :captain,
    has_one: :spaceship,
    wrapper: {
      each: lambda { |rel, record, &block|
        tresult = record.transaction_wrapper(outside_rescued_errors: ActiveRecord::RecordNotUnique) do
          puts "melon #{record.name} honey #{rel.to.name}"
          block.call # does the actual saving!
        end
        tresult.success?
      },
      all: lambda { |rel, &block|
        tresult = LaserBlasterNPCRound.transaction_wrapper do
          puts "can you eat #{rel.result.name} shoes"
          block.call
        end
        tresult.success?
      }
    }
  )
  extend Shiftable::Collection.new(belongs_to: :space_federation, has_many: :spaceships)
  belongs_to :captain
  belongs_to :space_federation
end

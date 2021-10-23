# frozen_string_literal: true

ActiveRecord::Schema.define(version: 0) do
  create_table :blasters, force: true do |t|
    t.string :name, null: false
    t.integer :ownership_changes, null: false, default: 0
    t.string :type, null: false
    t.integer :captain_id, null: false
  end

  create_table :captains, force: true do |t|
    t.string :name, null: false
    t.integer :space_federation_id, null: false
  end

  create_table :space_federations, force: true do |t|
    t.string :name, null: false
  end

  create_table :spaceships, force: true do |t|
    t.string :name, null: false
    t.integer :power, null: false
    t.integer :captain_id, null: false
    t.integer :space_federation_id, null: false
    t.integer :federation_changes, null: false, default: 0
    t.integer :captain_changes, null: false, default: 0
  end

  create_table :blaster_rounds, force: true do |t|
    t.string :name, null: false
    t.string :type, null: false
    t.integer :blaster_id, null: false
    t.integer :space_federation_id, null: false
    t.boolean :spent, null: false, default: false
  end
end

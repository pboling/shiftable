# frozen_string_literal: true

ActiveRecord::Schema.define(version: 0) do
  create_table :captains, force: true do |t|
    t.string :name, null: false
  end

  create_table :spaceships, force: true do |t|
    t.string :name, null: false
    t.integer :power, null: false
    t.integer :captain_id, null: false
  end

  create_table :blasters, force: true do |t|
    t.string :name, null: false
    t.integer :ownership_changes, null: false, default: 0
    t.string :type, null: false
    t.integer :captain_id, null: false
  end
end

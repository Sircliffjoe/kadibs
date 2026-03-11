# frozen_string_literal: true

class CreateLocations < ActiveRecord::Migration[8.0]
  def change
    create_table :locations do |t|
      t.references :organization, null: false, foreign_key: true

      # Self-referencing hierarchy (parent location)
      t.references :parent, foreign_key: { to_table: :locations }

      # Core identification
      t.string :name, null: false
      t.string :code, null: false
      t.string :location_type # plant, site, building, zone, area, room

      # Description
      t.text :description

      # Address
      t.jsonb :address, default: {}

      # Geolocation
      t.decimal :latitude, precision: 10, scale: 8
      t.decimal :longitude, precision: 11, scale: 8

      # Contact info
      t.string :contact_name
      t.string :contact_phone
      t.string :contact_email

      # Operational
      t.boolean :active, default: true

      # Custom fields
      t.jsonb :metadata, default: {}

      # Soft delete
      t.datetime :discarded_at

      t.timestamps
    end

    add_index :locations, [ :organization_id, :code ], unique: true
    add_index :locations, [ :organization_id, :location_type ]
    add_index :locations, [ :organization_id, :parent_id ]
    add_index :locations, :discarded_at
    add_index :locations, :active
  end
end

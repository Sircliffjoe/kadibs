# frozen_string_literal: true

class CreateAssetManagement < ActiveRecord::Migration[8.0]
  def change
    # =======================================================================
    # Asset Categories
    # =======================================================================
    create_table :asset_categories do |t|
      t.references :organization, null: false, foreign_key: true
      t.references :parent, foreign_key: { to_table: :asset_categories }

      t.string :name, null: false
      t.string :code, null: false
      t.text :description

      # Default attributes template for assets in this category
      t.jsonb :default_attributes, default: {}

      # Default PM requirements
      t.jsonb :default_pm_requirements, default: {}

      t.timestamps
    end

    add_index :asset_categories, [ :organization_id, :code ], unique: true
    add_index :asset_categories, [ :organization_id, :name ]

    # =======================================================================
    # Assets
    # =======================================================================
    create_table :assets do |t|
      t.references :organization, null: false, foreign_key: true
      t.references :location, foreign_key: true
      t.references :asset_category, foreign_key: true
      t.references :parent, foreign_key: { to_table: :assets }

      # =======================================================================
      # Identification
      # =======================================================================
      t.string :name, null: false
      t.string :code, null: false
      t.string :serial_number
      t.string :barcode
      t.string :qr_code_data  # Stored QR code content

      # =======================================================================
      # Classification
      # =======================================================================
      t.string :asset_type      # equipment, vehicle, facility, tool, infrastructure
      t.string :criticality     # critical, high, medium, low
      t.string :status, default: 'operational'  # operational, under_maintenance, out_of_service, decommissioned

      # =======================================================================
      # Technical Details
      # =======================================================================
      t.string :manufacturer
      t.string :model
      t.string :model_number
      t.integer :year_manufactured
      t.jsonb :specifications, default: {}

      # =======================================================================
      # Financial / Acquisition
      # =======================================================================
      t.decimal :purchase_price, precision: 15, scale: 2
      t.date :purchase_date
      t.string :purchase_order_number
      t.string :vendor_name

      t.decimal :current_value, precision: 15, scale: 2
      t.string :depreciation_method  # straight_line, declining_balance, units_of_production
      t.integer :useful_life_years
      t.decimal :salvage_value, precision: 15, scale: 2
      t.decimal :accumulated_depreciation, precision: 15, scale: 2, default: 0

      # =======================================================================
      # Warranty
      # =======================================================================
      t.date :warranty_start_date
      t.date :warranty_end_date
      t.text :warranty_terms
      t.string :warranty_provider
      t.string :warranty_contact

      # =======================================================================
      # Operational
      # =======================================================================
      t.date :installation_date
      t.date :commissioning_date
      t.date :last_maintenance_date
      t.date :next_maintenance_date

      # Meter tracking
      t.decimal :meter_reading, precision: 15, scale: 2
      t.string :meter_unit  # hours, km, miles, cycles, units
      t.datetime :meter_reading_at

      # Uptime tracking
      t.decimal :total_operating_hours, precision: 15, scale: 2, default: 0
      t.decimal :total_downtime_hours, precision: 15, scale: 2, default: 0

      # =======================================================================
      # Physical Location Details
      # =======================================================================
      t.string :room
      t.string :floor
      t.string :building
      t.string :gps_coordinates

      # =======================================================================
      # Maintenance Info
      # =======================================================================
      t.integer :work_order_count, default: 0
      t.integer :failure_count, default: 0
      t.decimal :total_maintenance_cost, precision: 15, scale: 2, default: 0

      # =======================================================================
      # Metadata
      # =======================================================================
      t.text :notes
      t.jsonb :custom_fields, default: {}
      t.jsonb :documents, default: []  # Array of document references

      # Insurance
      t.string :insurance_policy_number
      t.date :insurance_expiry_date

      # =======================================================================
      # Soft Delete
      # =======================================================================
      t.datetime :discarded_at

      t.timestamps
    end

    # Indexes for common queries
    add_index :assets, [ :organization_id, :code ], unique: true
    add_index :assets, [ :organization_id, :serial_number ]
    add_index :assets, [ :organization_id, :barcode ]
    add_index :assets, [ :organization_id, :status ]
    add_index :assets, [ :organization_id, :criticality ]
    add_index :assets, [ :organization_id, :asset_type ]
    add_index :assets, [ :organization_id, :location_id ]
    add_index :assets, [ :organization_id, :asset_category_id ]
    add_index :assets, :discarded_at
    add_index :assets, :next_maintenance_date
    add_index :assets, :warranty_end_date

    # =======================================================================
    # Asset Transfers (Movement History)
    # =======================================================================
    create_table :asset_transfers do |t|
      t.references :asset, null: false, foreign_key: true
      t.references :from_location, foreign_key: { to_table: :locations }
      t.references :to_location, null: false, foreign_key: { to_table: :locations }
      t.references :transferred_by, null: false, foreign_key: { to_table: :users }
      t.references :approved_by, foreign_key: { to_table: :users }

      t.datetime :transferred_at, null: false
      t.string :status, default: 'pending'  # pending, approved, completed, cancelled
      t.text :reason
      t.text :notes

      t.timestamps
    end

    add_index :asset_transfers, [ :asset_id, :transferred_at ]

    # =======================================================================
    # Meter Readings
    # =======================================================================
    create_table :meter_readings do |t|
      t.references :asset, null: false, foreign_key: true
      t.references :recorded_by, null: false, foreign_key: { to_table: :users }
      # work_order_id will be added in a later migration after work_orders table exists
      t.bigint :work_order_id

      t.string :meter_type, null: false  # hours, km, miles, cycles
      t.decimal :reading, precision: 15, scale: 2, null: false
      t.decimal :previous_reading, precision: 15, scale: 2
      t.decimal :usage_since_last, precision: 15, scale: 2

      t.datetime :recorded_at, null: false
      t.text :notes

      t.timestamps
    end

    add_index :meter_readings, [ :asset_id, :meter_type, :recorded_at ]
    add_index :meter_readings, [ :asset_id, :recorded_at ]
  end
end

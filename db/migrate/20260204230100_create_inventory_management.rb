# frozen_string_literal: true

class CreateInventoryManagement < ActiveRecord::Migration[8.0]
  def change
    # =======================================================================
    # Suppliers
    # =======================================================================
    create_table :suppliers do |t|
      t.references :organization, null: false, foreign_key: true

      t.string :name, null: false
      t.string :code
      t.string :supplier_type  # manufacturer, distributor, service_provider

      # Contact info
      t.string :contact_name
      t.string :contact_title
      t.string :email
      t.string :phone
      t.string :fax
      t.string :website

      # Address
      t.jsonb :address, default: {}

      # Banking/Payment
      t.string :payment_terms  # net_30, net_60, cod
      t.string :currency, default: 'USD'
      t.jsonb :bank_details, default: {}

      # Tax info
      t.string :tax_id

      # Performance
      t.decimal :rating, precision: 3, scale: 2  # 0.00 - 5.00
      t.integer :on_time_delivery_rate
      t.integer :quality_rating

      t.text :notes
      t.boolean :active, default: true
      t.boolean :preferred, default: false

      t.datetime :discarded_at

      t.timestamps
    end

    add_index :suppliers, [ :organization_id, :code ], unique: true, where: "code IS NOT NULL"
    add_index :suppliers, [ :organization_id, :name ]
    add_index :suppliers, :discarded_at

    # =======================================================================
    # Warehouses
    # =======================================================================
    create_table :warehouses do |t|
      t.references :organization, null: false, foreign_key: true
      t.references :location, foreign_key: true
      t.references :manager, foreign_key: { to_table: :users }

      t.string :name, null: false
      t.string :code, null: false
      t.text :description

      t.jsonb :address, default: {}

      t.boolean :active, default: true
      t.boolean :default_warehouse, default: false

      t.timestamps
    end

    add_index :warehouses, [ :organization_id, :code ], unique: true

    # =======================================================================
    # Stock Locations (within warehouses)
    # =======================================================================
    create_table :stock_locations do |t|
      t.references :warehouse, null: false, foreign_key: true

      t.string :name, null: false
      t.string :code, null: false

      # Physical location identifiers
      t.string :aisle
      t.string :rack
      t.string :shelf
      t.string :bin

      t.string :location_type  # shelf, bin, floor, cage, refrigerated
      t.decimal :capacity, precision: 10, scale: 2  # Optional capacity limit

      t.boolean :active, default: true

      t.timestamps
    end

    add_index :stock_locations, [ :warehouse_id, :code ], unique: true

    # =======================================================================
    # Part Categories
    # =======================================================================
    create_table :part_categories do |t|
      t.references :organization, null: false, foreign_key: true
      t.references :parent, foreign_key: { to_table: :part_categories }

      t.string :name, null: false
      t.string :code
      t.text :description

      t.timestamps
    end

    add_index :part_categories, [ :organization_id, :code ], unique: true, where: "code IS NOT NULL"

    # =======================================================================
    # Parts Catalog
    # =======================================================================
    create_table :parts do |t|
      t.references :organization, null: false, foreign_key: true
      t.references :part_category, foreign_key: true
      t.references :preferred_supplier, foreign_key: { to_table: :suppliers }
      t.references :default_stock_location, foreign_key: { to_table: :stock_locations }

      # =======================================================================
      # Identification
      # =======================================================================
      t.string :name, null: false
      t.string :part_number, null: false
      t.string :alternate_part_numbers, array: true, default: []
      t.text :description

      t.string :manufacturer
      t.string :manufacturer_part_number
      t.string :barcode

      # =======================================================================
      # Classification
      # =======================================================================
      t.string :part_type  # spare, consumable, tool, raw_material
      t.string :unit_of_measure, default: 'each'  # each, box, kg, liters, meters
      t.decimal :unit_conversion_factor, precision: 10, scale: 4, default: 1

      t.boolean :serialized, default: false  # Track individual serial numbers
      t.boolean :lot_tracked, default: false  # Track lot numbers

      # =======================================================================
      # Costing
      # =======================================================================
      t.decimal :unit_cost, precision: 15, scale: 4
      t.decimal :last_purchase_price, precision: 15, scale: 4
      t.decimal :average_cost, precision: 15, scale: 4
      t.string :costing_method, default: 'average'  # average, fifo, lifo, standard

      t.decimal :markup_percentage, precision: 5, scale: 2
      t.decimal :selling_price, precision: 15, scale: 4

      # =======================================================================
      # Stock Levels
      # =======================================================================
      t.decimal :minimum_stock, precision: 10, scale: 2, default: 0
      t.decimal :reorder_level, precision: 10, scale: 2
      t.decimal :reorder_quantity, precision: 10, scale: 2
      t.decimal :maximum_stock, precision: 10, scale: 2
      t.decimal :safety_stock, precision: 10, scale: 2

      # Current totals (denormalized for performance)
      t.decimal :quantity_on_hand, precision: 10, scale: 2, default: 0
      t.decimal :quantity_reserved, precision: 10, scale: 2, default: 0
      t.decimal :quantity_on_order, precision: 10, scale: 2, default: 0
      t.decimal :quantity_available, precision: 10, scale: 2, default: 0  # on_hand - reserved

      # =======================================================================
      # Lead Time & Ordering
      # =======================================================================
      t.integer :lead_time_days
      t.decimal :economic_order_quantity, precision: 10, scale: 2

      # =======================================================================
      # Physical Properties
      # =======================================================================
      t.decimal :weight, precision: 10, scale: 4
      t.string :weight_unit, default: 'kg'
      t.jsonb :dimensions, default: {}  # { length: 10, width: 5, height: 2, unit: 'cm' }

      # =======================================================================
      # Storage Requirements
      # =======================================================================
      t.boolean :hazardous, default: false
      t.string :hazard_class
      t.boolean :temperature_sensitive, default: false
      t.decimal :min_storage_temp, precision: 5, scale: 2
      t.decimal :max_storage_temp, precision: 5, scale: 2

      # =======================================================================
      # Shelf Life
      # =======================================================================
      t.boolean :perishable, default: false
      t.integer :shelf_life_days

      # =======================================================================
      # Metadata
      # =======================================================================
      t.jsonb :specifications, default: {}
      t.text :notes
      t.boolean :active, default: true
      t.datetime :discarded_at

      t.timestamps
    end

    add_index :parts, [ :organization_id, :part_number ], unique: true
    add_index :parts, [ :organization_id, :name ]
    add_index :parts, [ :organization_id, :barcode ], where: "barcode IS NOT NULL"
    add_index :parts, [ :organization_id, :part_category_id ]
    add_index :parts, :discarded_at
    add_index :parts, :quantity_available

    # =======================================================================
    # Asset-Part Relationship (which parts are used for which assets)
    # =======================================================================
    create_table :asset_parts do |t|
      t.references :asset, null: false, foreign_key: true
      t.references :part, null: false, foreign_key: true

      t.decimal :quantity_required, precision: 10, scale: 2, default: 1
      t.boolean :critical, default: false  # Is this part critical for the asset?
      t.text :notes

      t.timestamps
    end

    add_index :asset_parts, [ :asset_id, :part_id ], unique: true

    # =======================================================================
    # Inventory Items (Stock at specific locations)
    # =======================================================================
    create_table :inventory_items do |t|
      t.references :part, null: false, foreign_key: true
      t.references :stock_location, null: false, foreign_key: true

      t.decimal :quantity, precision: 10, scale: 2, null: false, default: 0
      t.decimal :reserved_quantity, precision: 10, scale: 2, default: 0

      t.string :lot_number
      t.string :serial_number
      t.date :expiry_date
      t.date :received_date

      t.decimal :unit_cost, precision: 15, scale: 4  # Cost at which this batch was received

      t.string :condition, default: 'new'  # new, refurbished, used

      t.timestamps
    end

    add_index :inventory_items, [ :part_id, :stock_location_id ]
    add_index :inventory_items, [ :part_id, :lot_number ], where: "lot_number IS NOT NULL"
    add_index :inventory_items, :expiry_date

    # =======================================================================
    # Stock Movements (Audit Trail)
    # =======================================================================
    create_table :stock_movements do |t|
      t.references :part, null: false, foreign_key: true
      t.references :stock_location, foreign_key: true
      t.references :destination_location, foreign_key: { to_table: :stock_locations }
      t.references :user, null: false, foreign_key: true
      # work_order_id will be added as FK in a later migration
      t.bigint :work_order_id
      # purchase_requisition_id - FK added after purchase_requisitions table is created
      t.bigint :purchase_requisition_id

      t.string :movement_type, null: false
      # Types: receipt, issue, transfer, adjustment_in, adjustment_out,
      #        reservation, release, return, scrap, cycle_count

      t.decimal :quantity, precision: 10, scale: 2, null: false
      t.decimal :unit_cost, precision: 15, scale: 4
      t.decimal :total_cost, precision: 15, scale: 2

      t.decimal :balance_before, precision: 10, scale: 2
      t.decimal :balance_after, precision: 10, scale: 2

      t.string :reference_type  # work_order, purchase_order, adjustment, etc.
      t.string :reference_number

      t.string :lot_number
      t.string :serial_number

      t.text :reason
      t.text :notes

      t.datetime :movement_date, null: false

      t.timestamps
    end

    add_index :stock_movements, [ :part_id, :created_at ]
    add_index :stock_movements, [ :part_id, :movement_type ]
    add_index :stock_movements, :reference_number

    # =======================================================================
    # Purchase Requisitions
    # =======================================================================
    create_table :purchase_requisitions do |t|
      t.references :organization, null: false, foreign_key: true
      t.references :requested_by, null: false, foreign_key: { to_table: :users }
      t.references :approved_by, foreign_key: { to_table: :users }
      t.references :supplier, foreign_key: true
      t.references :warehouse, foreign_key: true
      # work_order_id will be added as FK in a later migration
      t.bigint :work_order_id

      t.string :number, null: false
      t.string :status, default: 'draft'
      # Status: draft, pending_approval, approved, rejected, ordered,
      #         partially_received, received, cancelled, closed

      t.string :priority, default: 'normal'  # urgent, high, normal, low

      t.date :required_date
      t.date :expected_delivery_date

      t.text :notes
      t.text :rejection_reason

      t.datetime :submitted_at
      t.datetime :approved_at
      t.datetime :rejected_at
      t.datetime :ordered_at
      t.datetime :received_at

      t.decimal :subtotal, precision: 15, scale: 2
      t.decimal :tax_amount, precision: 15, scale: 2
      t.decimal :shipping_cost, precision: 15, scale: 2
      t.decimal :total_amount, precision: 15, scale: 2

      t.string :currency, default: 'USD'

      # External PO reference
      t.string :purchase_order_number

      t.timestamps
    end

    add_index :purchase_requisitions, [ :organization_id, :number ], unique: true
    add_index :purchase_requisitions, [ :organization_id, :status ]

    # =======================================================================
    # Purchase Requisition Items
    # =======================================================================
    create_table :purchase_requisition_items do |t|
      t.references :purchase_requisition, null: false, foreign_key: true
      t.references :part, null: false, foreign_key: true

      t.decimal :quantity_requested, precision: 10, scale: 2, null: false
      t.decimal :quantity_approved, precision: 10, scale: 2
      t.decimal :quantity_ordered, precision: 10, scale: 2
      t.decimal :quantity_received, precision: 10, scale: 2, default: 0

      t.decimal :unit_price, precision: 15, scale: 4
      t.decimal :total_price, precision: 15, scale: 2

      t.text :notes

      t.timestamps
    end

    add_index :purchase_requisition_items, [ :purchase_requisition_id, :part_id ]

    # =======================================================================
    # Goods Receipts
    # =======================================================================
    create_table :goods_receipts do |t|
      t.references :organization, null: false, foreign_key: true
      t.references :purchase_requisition, foreign_key: true
      t.references :supplier, foreign_key: true
      t.references :warehouse, null: false, foreign_key: true
      t.references :received_by, null: false, foreign_key: { to_table: :users }

      t.string :number, null: false
      t.date :receipt_date, null: false

      t.string :delivery_note_number
      t.string :invoice_number

      t.string :status, default: 'draft'  # draft, completed, cancelled

      t.text :notes

      t.timestamps
    end

    add_index :goods_receipts, [ :organization_id, :number ], unique: true

    create_table :goods_receipt_items do |t|
      t.references :goods_receipt, null: false, foreign_key: true
      t.references :part, null: false, foreign_key: true
      t.references :purchase_requisition_item, foreign_key: true
      t.references :stock_location, null: false, foreign_key: true

      t.decimal :quantity_expected, precision: 10, scale: 2
      t.decimal :quantity_received, precision: 10, scale: 2, null: false
      t.decimal :quantity_rejected, precision: 10, scale: 2, default: 0

      t.decimal :unit_cost, precision: 15, scale: 4

      t.string :lot_number
      t.date :expiry_date

      t.string :condition, default: 'new'
      t.text :rejection_reason
      t.text :notes

      t.timestamps
    end

    # Stock movements purchase_requisition FK - self-referencing within this migration
    add_foreign_key :stock_movements, :purchase_requisitions, column: :purchase_requisition_id
  end
end

# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_02_12_230454) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "asset_categories", force: :cascade do |t|
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.jsonb "default_attributes", default: {}
    t.jsonb "default_pm_requirements", default: {}
    t.text "description"
    t.datetime "discarded_at"
    t.string "name", null: false
    t.bigint "organization_id", null: false
    t.bigint "parent_id"
    t.datetime "updated_at", null: false
    t.index ["discarded_at"], name: "index_asset_categories_on_discarded_at"
    t.index ["organization_id", "code"], name: "index_asset_categories_on_organization_id_and_code", unique: true
    t.index ["organization_id", "name"], name: "index_asset_categories_on_organization_id_and_name"
    t.index ["organization_id"], name: "index_asset_categories_on_organization_id"
    t.index ["parent_id"], name: "index_asset_categories_on_parent_id"
  end

  create_table "asset_parts", force: :cascade do |t|
    t.bigint "asset_id", null: false
    t.datetime "created_at", null: false
    t.boolean "critical", default: false
    t.text "notes"
    t.bigint "part_id", null: false
    t.decimal "quantity_required", precision: 10, scale: 2, default: "1.0"
    t.datetime "updated_at", null: false
    t.index ["asset_id", "part_id"], name: "index_asset_parts_on_asset_id_and_part_id", unique: true
    t.index ["asset_id"], name: "index_asset_parts_on_asset_id"
    t.index ["part_id"], name: "index_asset_parts_on_part_id"
  end

  create_table "asset_transfers", force: :cascade do |t|
    t.bigint "approved_by_id"
    t.bigint "asset_id", null: false
    t.datetime "created_at", null: false
    t.bigint "from_location_id"
    t.text "notes"
    t.text "reason"
    t.string "status", default: "pending"
    t.bigint "to_location_id", null: false
    t.datetime "transferred_at", null: false
    t.bigint "transferred_by_id", null: false
    t.datetime "updated_at", null: false
    t.index ["approved_by_id"], name: "index_asset_transfers_on_approved_by_id"
    t.index ["asset_id", "transferred_at"], name: "index_asset_transfers_on_asset_id_and_transferred_at"
    t.index ["asset_id"], name: "index_asset_transfers_on_asset_id"
    t.index ["from_location_id"], name: "index_asset_transfers_on_from_location_id"
    t.index ["to_location_id"], name: "index_asset_transfers_on_to_location_id"
    t.index ["transferred_by_id"], name: "index_asset_transfers_on_transferred_by_id"
  end

  create_table "assets", force: :cascade do |t|
    t.decimal "accumulated_depreciation", precision: 15, scale: 2, default: "0.0"
    t.bigint "asset_category_id"
    t.string "asset_type"
    t.string "barcode"
    t.string "building"
    t.string "code", null: false
    t.date "commissioning_date"
    t.datetime "created_at", null: false
    t.string "criticality"
    t.decimal "current_value", precision: 15, scale: 2
    t.jsonb "custom_fields", default: {}
    t.string "depreciation_method"
    t.text "description"
    t.datetime "discarded_at"
    t.jsonb "documents", default: []
    t.integer "failure_count", default: 0
    t.string "floor"
    t.string "gps_coordinates"
    t.date "installation_date"
    t.date "insurance_expiry_date"
    t.string "insurance_policy_number"
    t.date "last_maintenance_date"
    t.bigint "location_id"
    t.string "manufacturer"
    t.decimal "meter_reading", precision: 15, scale: 2
    t.datetime "meter_reading_at"
    t.string "meter_unit"
    t.string "model"
    t.string "model_number"
    t.string "name", null: false
    t.date "next_maintenance_date"
    t.bigint "organization_id", null: false
    t.bigint "parent_id"
    t.date "purchase_date"
    t.string "purchase_order_number"
    t.decimal "purchase_price", precision: 15, scale: 2
    t.string "qr_code_data"
    t.string "room"
    t.decimal "salvage_value", precision: 15, scale: 2
    t.string "serial_number"
    t.jsonb "specifications", default: {}
    t.string "status", default: "operational"
    t.decimal "total_downtime_hours", precision: 15, scale: 2, default: "0.0"
    t.decimal "total_maintenance_cost", precision: 15, scale: 2, default: "0.0"
    t.decimal "total_operating_hours", precision: 15, scale: 2, default: "0.0"
    t.datetime "updated_at", null: false
    t.integer "useful_life_years"
    t.string "vendor_name"
    t.string "warranty_contact"
    t.date "warranty_end_date"
    t.string "warranty_provider"
    t.date "warranty_start_date"
    t.text "warranty_terms"
    t.integer "work_order_count", default: 0
    t.integer "year_manufactured"
    t.index ["asset_category_id"], name: "index_assets_on_asset_category_id"
    t.index ["discarded_at"], name: "index_assets_on_discarded_at"
    t.index ["location_id"], name: "index_assets_on_location_id"
    t.index ["next_maintenance_date"], name: "index_assets_on_next_maintenance_date"
    t.index ["organization_id", "asset_category_id"], name: "index_assets_on_organization_id_and_asset_category_id"
    t.index ["organization_id", "asset_type"], name: "index_assets_on_organization_id_and_asset_type"
    t.index ["organization_id", "barcode"], name: "index_assets_on_organization_id_and_barcode"
    t.index ["organization_id", "code"], name: "index_assets_on_organization_id_and_code", unique: true
    t.index ["organization_id", "criticality"], name: "index_assets_on_organization_id_and_criticality"
    t.index ["organization_id", "location_id"], name: "index_assets_on_organization_id_and_location_id"
    t.index ["organization_id", "serial_number"], name: "index_assets_on_organization_id_and_serial_number"
    t.index ["organization_id", "status"], name: "index_assets_on_organization_id_and_status"
    t.index ["organization_id"], name: "index_assets_on_organization_id"
    t.index ["parent_id"], name: "index_assets_on_parent_id"
    t.index ["warranty_end_date"], name: "index_assets_on_warranty_end_date"
  end

  create_table "failure_codes", force: :cascade do |t|
    t.boolean "active", default: true
    t.string "code", null: false
    t.string "code_type", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name", null: false
    t.bigint "organization_id", null: false
    t.bigint "parent_id"
    t.datetime "updated_at", null: false
    t.index ["organization_id", "code"], name: "index_failure_codes_on_organization_id_and_code", unique: true
    t.index ["organization_id", "code_type"], name: "index_failure_codes_on_organization_id_and_code_type"
    t.index ["organization_id", "parent_id"], name: "index_failure_codes_on_organization_id_and_parent_id"
    t.index ["organization_id"], name: "index_failure_codes_on_organization_id"
    t.index ["parent_id"], name: "index_failure_codes_on_parent_id"
  end

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.datetime "created_at"
    t.string "scope"
    t.string "slug", null: false
    t.integer "sluggable_id", null: false
    t.string "sluggable_type", limit: 50
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type"
    t.index ["sluggable_type", "sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_type_and_sluggable_id"
  end

  create_table "goods_receipt_items", force: :cascade do |t|
    t.string "condition", default: "new"
    t.datetime "created_at", null: false
    t.date "expiry_date"
    t.bigint "goods_receipt_id", null: false
    t.string "lot_number"
    t.text "notes"
    t.bigint "part_id", null: false
    t.bigint "purchase_requisition_item_id"
    t.decimal "quantity_expected", precision: 10, scale: 2
    t.decimal "quantity_received", precision: 10, scale: 2, null: false
    t.decimal "quantity_rejected", precision: 10, scale: 2, default: "0.0"
    t.text "rejection_reason"
    t.bigint "stock_location_id", null: false
    t.decimal "unit_cost", precision: 15, scale: 4
    t.datetime "updated_at", null: false
    t.index ["goods_receipt_id"], name: "index_goods_receipt_items_on_goods_receipt_id"
    t.index ["part_id"], name: "index_goods_receipt_items_on_part_id"
    t.index ["purchase_requisition_item_id"], name: "index_goods_receipt_items_on_purchase_requisition_item_id"
    t.index ["stock_location_id"], name: "index_goods_receipt_items_on_stock_location_id"
  end

  create_table "goods_receipts", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "delivery_note_number"
    t.string "invoice_number"
    t.text "notes"
    t.string "number", null: false
    t.bigint "organization_id", null: false
    t.bigint "purchase_requisition_id"
    t.date "receipt_date", null: false
    t.bigint "received_by_id", null: false
    t.string "status", default: "draft"
    t.bigint "supplier_id"
    t.datetime "updated_at", null: false
    t.bigint "warehouse_id", null: false
    t.index ["organization_id", "number"], name: "index_goods_receipts_on_organization_id_and_number", unique: true
    t.index ["organization_id"], name: "index_goods_receipts_on_organization_id"
    t.index ["purchase_requisition_id"], name: "index_goods_receipts_on_purchase_requisition_id"
    t.index ["received_by_id"], name: "index_goods_receipts_on_received_by_id"
    t.index ["supplier_id"], name: "index_goods_receipts_on_supplier_id"
    t.index ["warehouse_id"], name: "index_goods_receipts_on_warehouse_id"
  end

  create_table "inspection_items", force: :cascade do |t|
    t.boolean "checked", default: false
    t.datetime "created_at", null: false
    t.string "description", null: false
    t.bigint "inspection_id", null: false
    t.string "notes"
    t.integer "position"
    t.datetime "updated_at", null: false
    t.index ["inspection_id"], name: "index_inspection_items_on_inspection_id"
  end

  create_table "inspections", force: :cascade do |t|
    t.bigint "asset_id"
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.text "description"
    t.datetime "discarded_at"
    t.bigint "inspector_id"
    t.bigint "organization_id", null: false
    t.date "scheduled_date"
    t.string "status", default: "pending", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.bigint "work_order_id"
    t.index ["asset_id"], name: "index_inspections_on_asset_id"
    t.index ["discarded_at"], name: "index_inspections_on_discarded_at"
    t.index ["inspector_id"], name: "index_inspections_on_inspector_id"
    t.index ["organization_id"], name: "index_inspections_on_organization_id"
    t.index ["work_order_id"], name: "index_inspections_on_work_order_id"
  end

  create_table "inventory_items", force: :cascade do |t|
    t.string "condition", default: "new"
    t.datetime "created_at", null: false
    t.date "expiry_date"
    t.string "lot_number"
    t.bigint "part_id", null: false
    t.decimal "quantity", precision: 10, scale: 2, default: "0.0", null: false
    t.date "received_date"
    t.decimal "reserved_quantity", precision: 10, scale: 2, default: "0.0"
    t.string "serial_number"
    t.bigint "stock_location_id", null: false
    t.decimal "unit_cost", precision: 15, scale: 4
    t.datetime "updated_at", null: false
    t.index ["expiry_date"], name: "index_inventory_items_on_expiry_date"
    t.index ["part_id", "lot_number"], name: "index_inventory_items_on_part_id_and_lot_number", where: "(lot_number IS NOT NULL)"
    t.index ["part_id", "stock_location_id"], name: "index_inventory_items_on_part_id_and_stock_location_id"
    t.index ["part_id"], name: "index_inventory_items_on_part_id"
    t.index ["stock_location_id"], name: "index_inventory_items_on_stock_location_id"
  end

  create_table "locations", force: :cascade do |t|
    t.boolean "active", default: true
    t.jsonb "address", default: {}
    t.string "code", null: false
    t.string "contact_email"
    t.string "contact_name"
    t.string "contact_phone"
    t.datetime "created_at", null: false
    t.text "description"
    t.datetime "discarded_at"
    t.decimal "latitude", precision: 10, scale: 8
    t.string "location_type"
    t.decimal "longitude", precision: 11, scale: 8
    t.jsonb "metadata", default: {}
    t.string "name", null: false
    t.bigint "organization_id", null: false
    t.bigint "parent_id"
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_locations_on_active"
    t.index ["discarded_at"], name: "index_locations_on_discarded_at"
    t.index ["organization_id", "code"], name: "index_locations_on_organization_id_and_code", unique: true
    t.index ["organization_id", "location_type"], name: "index_locations_on_organization_id_and_location_type"
    t.index ["organization_id", "parent_id"], name: "index_locations_on_organization_id_and_parent_id"
    t.index ["organization_id"], name: "index_locations_on_organization_id"
    t.index ["parent_id"], name: "index_locations_on_parent_id"
  end

  create_table "meter_readings", force: :cascade do |t|
    t.bigint "asset_id", null: false
    t.datetime "created_at", null: false
    t.string "meter_type", null: false
    t.text "notes"
    t.decimal "previous_reading", precision: 15, scale: 2
    t.decimal "reading", precision: 15, scale: 2, null: false
    t.datetime "recorded_at", null: false
    t.bigint "recorded_by_id", null: false
    t.datetime "updated_at", null: false
    t.decimal "usage_since_last", precision: 15, scale: 2
    t.bigint "work_order_id"
    t.index ["asset_id", "meter_type", "recorded_at"], name: "idx_on_asset_id_meter_type_recorded_at_bc8dc59ad4"
    t.index ["asset_id", "recorded_at"], name: "index_meter_readings_on_asset_id_and_recorded_at"
    t.index ["asset_id"], name: "index_meter_readings_on_asset_id"
    t.index ["recorded_by_id"], name: "index_meter_readings_on_recorded_by_id"
    t.index ["work_order_id"], name: "index_meter_readings_on_work_order_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.string "action"
    t.bigint "actor_id"
    t.datetime "created_at", null: false
    t.bigint "notifiable_id", null: false
    t.string "notifiable_type", null: false
    t.bigint "organization_id", null: false
    t.datetime "read_at"
    t.bigint "recipient_id", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_id"], name: "index_notifications_on_actor_id"
    t.index ["notifiable_type", "notifiable_id"], name: "index_notifications_on_notifiable"
    t.index ["organization_id"], name: "index_notifications_on_organization_id"
    t.index ["recipient_id"], name: "index_notifications_on_recipient_id"
  end

  create_table "organizations", force: :cascade do |t|
    t.string "address"
    t.string "city"
    t.string "company_size"
    t.string "country"
    t.datetime "created_at", null: false
    t.string "currency", default: "USD"
    t.string "date_format", default: "%Y-%m-%d"
    t.datetime "discarded_at"
    t.string "domain"
    t.string "email"
    t.string "industry"
    t.string "logo"
    t.string "name", null: false
    t.string "phone"
    t.string "plan", default: "starter"
    t.jsonb "settings", default: {}
    t.string "slug", null: false
    t.string "state"
    t.string "status", default: "active"
    t.string "time_format", default: "%H:%M"
    t.string "timezone", default: "UTC"
    t.datetime "trial_ends_at"
    t.datetime "updated_at", null: false
    t.string "website"
    t.string "zip_code"
    t.index ["discarded_at"], name: "index_organizations_on_discarded_at"
    t.index ["name"], name: "index_organizations_on_name"
    t.index ["plan"], name: "index_organizations_on_plan"
    t.index ["slug"], name: "index_organizations_on_slug", unique: true
    t.index ["status"], name: "index_organizations_on_status"
  end

  create_table "part_categories", force: :cascade do |t|
    t.string "code"
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name", null: false
    t.bigint "organization_id", null: false
    t.bigint "parent_id"
    t.datetime "updated_at", null: false
    t.index ["organization_id", "code"], name: "index_part_categories_on_organization_id_and_code", unique: true, where: "(code IS NOT NULL)"
    t.index ["organization_id"], name: "index_part_categories_on_organization_id"
    t.index ["parent_id"], name: "index_part_categories_on_parent_id"
  end

  create_table "parts", force: :cascade do |t|
    t.boolean "active", default: true
    t.string "alternate_part_numbers", default: [], array: true
    t.decimal "average_cost", precision: 15, scale: 4
    t.string "barcode"
    t.string "costing_method", default: "average"
    t.datetime "created_at", null: false
    t.bigint "default_stock_location_id"
    t.text "description"
    t.jsonb "dimensions", default: {}
    t.datetime "discarded_at"
    t.decimal "economic_order_quantity", precision: 10, scale: 2
    t.string "hazard_class"
    t.boolean "hazardous", default: false
    t.decimal "last_purchase_price", precision: 15, scale: 4
    t.integer "lead_time_days"
    t.boolean "lot_tracked", default: false
    t.string "manufacturer"
    t.string "manufacturer_part_number"
    t.decimal "markup_percentage", precision: 5, scale: 2
    t.decimal "max_storage_temp", precision: 5, scale: 2
    t.decimal "maximum_stock", precision: 10, scale: 2
    t.decimal "min_storage_temp", precision: 5, scale: 2
    t.decimal "minimum_stock", precision: 10, scale: 2, default: "0.0"
    t.string "name", null: false
    t.text "notes"
    t.bigint "organization_id", null: false
    t.bigint "part_category_id"
    t.string "part_number", null: false
    t.string "part_type"
    t.boolean "perishable", default: false
    t.bigint "preferred_supplier_id"
    t.decimal "quantity_available", precision: 10, scale: 2, default: "0.0"
    t.decimal "quantity_on_hand", precision: 10, scale: 2, default: "0.0"
    t.decimal "quantity_on_order", precision: 10, scale: 2, default: "0.0"
    t.decimal "quantity_reserved", precision: 10, scale: 2, default: "0.0"
    t.decimal "reorder_level", precision: 10, scale: 2
    t.decimal "reorder_quantity", precision: 10, scale: 2
    t.decimal "safety_stock", precision: 10, scale: 2
    t.decimal "selling_price", precision: 15, scale: 4
    t.boolean "serialized", default: false
    t.integer "shelf_life_days"
    t.jsonb "specifications", default: {}
    t.boolean "temperature_sensitive", default: false
    t.decimal "unit_conversion_factor", precision: 10, scale: 4, default: "1.0"
    t.decimal "unit_cost", precision: 15, scale: 4
    t.string "unit_of_measure", default: "each"
    t.datetime "updated_at", null: false
    t.decimal "weight", precision: 10, scale: 4
    t.string "weight_unit", default: "kg"
    t.index ["default_stock_location_id"], name: "index_parts_on_default_stock_location_id"
    t.index ["discarded_at"], name: "index_parts_on_discarded_at"
    t.index ["organization_id", "barcode"], name: "index_parts_on_organization_id_and_barcode", where: "(barcode IS NOT NULL)"
    t.index ["organization_id", "name"], name: "index_parts_on_organization_id_and_name"
    t.index ["organization_id", "part_category_id"], name: "index_parts_on_organization_id_and_part_category_id"
    t.index ["organization_id", "part_number"], name: "index_parts_on_organization_id_and_part_number", unique: true
    t.index ["organization_id"], name: "index_parts_on_organization_id"
    t.index ["part_category_id"], name: "index_parts_on_part_category_id"
    t.index ["preferred_supplier_id"], name: "index_parts_on_preferred_supplier_id"
    t.index ["quantity_available"], name: "index_parts_on_quantity_available"
  end

  create_table "pm_occurrences", force: :cascade do |t|
    t.decimal "actual_meter_reading", precision: 15, scale: 2
    t.date "completed_date"
    t.datetime "created_at", null: false
    t.bigint "preventive_maintenance_schedule_id", null: false
    t.date "scheduled_date", null: false
    t.decimal "scheduled_meter_reading", precision: 15, scale: 2
    t.text "skip_reason"
    t.bigint "skipped_by_id"
    t.string "status", default: "scheduled"
    t.datetime "updated_at", null: false
    t.bigint "work_order_id"
    t.index ["preventive_maintenance_schedule_id", "scheduled_date"], name: "idx_on_preventive_maintenance_schedule_id_scheduled_5c78403f3e"
    t.index ["preventive_maintenance_schedule_id", "status"], name: "idx_on_preventive_maintenance_schedule_id_status_8480d423e0"
    t.index ["preventive_maintenance_schedule_id"], name: "index_pm_occurrences_on_preventive_maintenance_schedule_id"
    t.index ["skipped_by_id"], name: "index_pm_occurrences_on_skipped_by_id"
    t.index ["work_order_id"], name: "index_pm_occurrences_on_work_order_id"
  end

  create_table "pm_templates", force: :cascade do |t|
    t.boolean "active", default: true
    t.bigint "asset_category_id"
    t.string "code"
    t.datetime "created_at", null: false
    t.text "description"
    t.decimal "estimated_cost", precision: 15, scale: 2
    t.decimal "estimated_hours", precision: 8, scale: 2
    t.string "name", null: false
    t.bigint "organization_id", null: false
    t.jsonb "required_parts", default: []
    t.jsonb "required_skills", default: []
    t.jsonb "safety_requirements", default: []
    t.jsonb "tasks", default: []
    t.datetime "updated_at", null: false
    t.index ["asset_category_id"], name: "index_pm_templates_on_asset_category_id"
    t.index ["organization_id", "code"], name: "index_pm_templates_on_organization_id_and_code", unique: true, where: "(code IS NOT NULL)"
    t.index ["organization_id", "name"], name: "index_pm_templates_on_organization_id_and_name"
    t.index ["organization_id"], name: "index_pm_templates_on_organization_id"
  end

  create_table "preventive_maintenance_schedules", force: :cascade do |t|
    t.boolean "active", default: true
    t.bigint "asset_id", null: false
    t.jsonb "checklist_template", default: []
    t.string "code"
    t.integer "completed_occurrences", default: 0
    t.decimal "compliance_rate", precision: 5, scale: 2, default: "100.0"
    t.datetime "created_at", null: false
    t.bigint "default_assignee_id"
    t.text "description"
    t.date "end_date"
    t.bigint "escalation_contact_id"
    t.integer "escalation_days"
    t.decimal "estimated_cost", precision: 15, scale: 2
    t.decimal "estimated_hours", precision: 8, scale: 2
    t.string "frequency_unit"
    t.integer "frequency_value"
    t.text "instructions"
    t.date "last_completed_date"
    t.date "last_generated_date"
    t.decimal "last_meter_reading", precision: 15, scale: 2
    t.integer "lead_time_days", default: 7
    t.bigint "location_id"
    t.decimal "meter_interval", precision: 15, scale: 2
    t.string "meter_type"
    t.decimal "meter_warning_threshold", precision: 15, scale: 2
    t.integer "missed_occurrences", default: 0
    t.string "name", null: false
    t.date "next_due_date"
    t.decimal "next_meter_due", precision: 15, scale: 2
    t.integer "notification_days", default: 3
    t.bigint "organization_id", null: false
    t.jsonb "parts_template", default: []
    t.bigint "pm_template_id"
    t.integer "preferred_day_of_month"
    t.integer "preferred_day_of_week"
    t.time "preferred_time"
    t.string "priority", default: "medium"
    t.text "safety_notes"
    t.string "schedule_type", null: false
    t.jsonb "seasonal_months", default: []
    t.boolean "skip_holidays", default: false
    t.boolean "skip_weekends", default: false
    t.date "start_date"
    t.integer "total_occurrences", default: 0
    t.datetime "updated_at", null: false
    t.string "work_order_type", default: "preventive"
    t.index ["asset_id"], name: "index_preventive_maintenance_schedules_on_asset_id"
    t.index ["default_assignee_id"], name: "index_preventive_maintenance_schedules_on_default_assignee_id"
    t.index ["escalation_contact_id"], name: "idx_on_escalation_contact_id_bb7509492c"
    t.index ["location_id"], name: "index_preventive_maintenance_schedules_on_location_id"
    t.index ["next_meter_due"], name: "index_preventive_maintenance_schedules_on_next_meter_due", where: "(meter_type IS NOT NULL)"
    t.index ["organization_id", "active"], name: "idx_on_organization_id_active_f337289ace"
    t.index ["organization_id", "asset_id"], name: "idx_on_organization_id_asset_id_2814e1d27f"
    t.index ["organization_id", "next_due_date"], name: "idx_on_organization_id_next_due_date_b5b127c4bb"
    t.index ["organization_id"], name: "index_preventive_maintenance_schedules_on_organization_id"
    t.index ["pm_template_id"], name: "index_preventive_maintenance_schedules_on_pm_template_id"
  end

  create_table "purchase_requisition_items", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "notes"
    t.bigint "part_id", null: false
    t.bigint "purchase_requisition_id", null: false
    t.decimal "quantity_approved", precision: 10, scale: 2
    t.decimal "quantity_ordered", precision: 10, scale: 2
    t.decimal "quantity_received", precision: 10, scale: 2, default: "0.0"
    t.decimal "quantity_requested", precision: 10, scale: 2, null: false
    t.decimal "total_price", precision: 15, scale: 2
    t.decimal "unit_price", precision: 15, scale: 4
    t.datetime "updated_at", null: false
    t.index ["part_id"], name: "index_purchase_requisition_items_on_part_id"
    t.index ["purchase_requisition_id", "part_id"], name: "idx_on_purchase_requisition_id_part_id_1e3023a3a2"
    t.index ["purchase_requisition_id"], name: "index_purchase_requisition_items_on_purchase_requisition_id"
  end

  create_table "purchase_requisitions", force: :cascade do |t|
    t.datetime "approved_at"
    t.bigint "approved_by_id"
    t.datetime "created_at", null: false
    t.string "currency", default: "USD"
    t.date "expected_delivery_date"
    t.text "notes"
    t.string "number", null: false
    t.datetime "ordered_at"
    t.bigint "organization_id", null: false
    t.string "priority", default: "normal"
    t.string "purchase_order_number"
    t.datetime "received_at"
    t.datetime "rejected_at"
    t.text "rejection_reason"
    t.bigint "requested_by_id", null: false
    t.date "required_date"
    t.text "shipping_address"
    t.decimal "shipping_cost", precision: 15, scale: 2
    t.string "status", default: "draft"
    t.datetime "submitted_at"
    t.decimal "subtotal", precision: 15, scale: 2
    t.bigint "supplier_id"
    t.decimal "tax_amount", precision: 15, scale: 2
    t.decimal "total_amount", precision: 15, scale: 2
    t.datetime "updated_at", null: false
    t.bigint "warehouse_id"
    t.bigint "work_order_id"
    t.index ["approved_by_id"], name: "index_purchase_requisitions_on_approved_by_id"
    t.index ["organization_id", "number"], name: "index_purchase_requisitions_on_organization_id_and_number", unique: true
    t.index ["organization_id", "status"], name: "index_purchase_requisitions_on_organization_id_and_status"
    t.index ["organization_id"], name: "index_purchase_requisitions_on_organization_id"
    t.index ["requested_by_id"], name: "index_purchase_requisitions_on_requested_by_id"
    t.index ["supplier_id"], name: "index_purchase_requisitions_on_supplier_id"
    t.index ["warehouse_id"], name: "index_purchase_requisitions_on_warehouse_id"
    t.index ["work_order_id"], name: "index_purchase_requisitions_on_work_order_id"
  end

  create_table "roles", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name", null: false
    t.bigint "organization_id", null: false
    t.jsonb "permissions", default: {}
    t.string "slug", null: false
    t.boolean "system_role", default: false
    t.datetime "updated_at", null: false
    t.index ["organization_id", "name"], name: "index_roles_on_organization_id_and_name"
    t.index ["organization_id", "slug"], name: "index_roles_on_organization_id_and_slug", unique: true
    t.index ["organization_id"], name: "index_roles_on_organization_id"
    t.index ["system_role"], name: "index_roles_on_system_role"
  end

  create_table "stock_locations", force: :cascade do |t|
    t.boolean "active", default: true
    t.string "aisle"
    t.string "bin"
    t.decimal "capacity", precision: 10, scale: 2
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.string "location_type"
    t.string "name", null: false
    t.string "rack"
    t.string "shelf"
    t.datetime "updated_at", null: false
    t.bigint "warehouse_id", null: false
    t.index ["warehouse_id", "code"], name: "index_stock_locations_on_warehouse_id_and_code", unique: true
    t.index ["warehouse_id"], name: "index_stock_locations_on_warehouse_id"
  end

  create_table "stock_movements", force: :cascade do |t|
    t.decimal "balance_after", precision: 10, scale: 2
    t.decimal "balance_before", precision: 10, scale: 2
    t.datetime "created_at", null: false
    t.bigint "destination_location_id"
    t.string "lot_number"
    t.datetime "movement_date", null: false
    t.string "movement_type", null: false
    t.text "notes"
    t.bigint "part_id", null: false
    t.bigint "purchase_requisition_id"
    t.decimal "quantity", precision: 10, scale: 2, null: false
    t.text "reason"
    t.string "reference_number"
    t.string "reference_type"
    t.string "serial_number"
    t.bigint "stock_location_id"
    t.decimal "total_cost", precision: 15, scale: 2
    t.decimal "unit_cost", precision: 15, scale: 4
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.bigint "work_order_id"
    t.index ["destination_location_id"], name: "index_stock_movements_on_destination_location_id"
    t.index ["part_id", "created_at"], name: "index_stock_movements_on_part_id_and_created_at"
    t.index ["part_id", "movement_type"], name: "index_stock_movements_on_part_id_and_movement_type"
    t.index ["part_id"], name: "index_stock_movements_on_part_id"
    t.index ["reference_number"], name: "index_stock_movements_on_reference_number"
    t.index ["stock_location_id"], name: "index_stock_movements_on_stock_location_id"
    t.index ["user_id"], name: "index_stock_movements_on_user_id"
    t.index ["work_order_id"], name: "index_stock_movements_on_work_order_id"
  end

  create_table "suppliers", force: :cascade do |t|
    t.boolean "active", default: true
    t.jsonb "address", default: {}
    t.jsonb "bank_details", default: {}
    t.string "code"
    t.string "contact_name"
    t.string "contact_title"
    t.datetime "created_at", null: false
    t.string "currency", default: "USD"
    t.datetime "discarded_at"
    t.string "email"
    t.string "fax"
    t.string "name", null: false
    t.text "notes"
    t.integer "on_time_delivery_rate"
    t.bigint "organization_id", null: false
    t.string "payment_terms"
    t.string "phone"
    t.boolean "preferred", default: false
    t.integer "quality_rating"
    t.decimal "rating", precision: 3, scale: 2
    t.string "supplier_type"
    t.string "tax_id"
    t.datetime "updated_at", null: false
    t.string "website"
    t.index ["discarded_at"], name: "index_suppliers_on_discarded_at"
    t.index ["organization_id", "code"], name: "index_suppliers_on_organization_id_and_code", unique: true, where: "(code IS NOT NULL)"
    t.index ["organization_id", "name"], name: "index_suppliers_on_organization_id_and_name"
    t.index ["organization_id"], name: "index_suppliers_on_organization_id"
  end

  create_table "user_roles", force: :cascade do |t|
    t.bigint "assigned_by_id"
    t.datetime "created_at", null: false
    t.bigint "role_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["assigned_by_id"], name: "index_user_roles_on_assigned_by_id"
    t.index ["role_id"], name: "index_user_roles_on_role_id"
    t.index ["user_id", "role_id"], name: "index_user_roles_on_user_id_and_role_id", unique: true
    t.index ["user_id"], name: "index_user_roles_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.boolean "active", default: true
    t.string "avatar"
    t.datetime "confirmation_sent_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "created_at", null: false
    t.datetime "current_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "department"
    t.datetime "discarded_at"
    t.string "email", null: false
    t.boolean "email_notifications"
    t.string "employee_id"
    t.string "encrypted_password", default: "", null: false
    t.integer "failed_attempts", default: 0, null: false
    t.string "first_name", null: false
    t.string "job_title"
    t.string "last_name", null: false
    t.datetime "last_sign_in_at"
    t.string "last_sign_in_ip"
    t.string "locale", default: "en"
    t.datetime "locked_at"
    t.bigint "organization_id", null: false
    t.string "phone"
    t.jsonb "preferences", default: {}
    t.boolean "push_notifications"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.integer "sign_in_count", default: 0, null: false
    t.boolean "sms_notifications"
    t.boolean "super_admin", default: false
    t.string "timezone"
    t.string "unconfirmed_email"
    t.string "unlock_token"
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_users_on_active"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["discarded_at"], name: "index_users_on_discarded_at"
    t.index ["email"], name: "index_users_on_email"
    t.index ["organization_id", "email"], name: "index_users_on_organization_id_and_email", unique: true
    t.index ["organization_id", "employee_id"], name: "index_users_on_organization_id_and_employee_id", unique: true, where: "(employee_id IS NOT NULL)"
    t.index ["organization_id"], name: "index_users_on_organization_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["super_admin"], name: "index_users_on_super_admin"
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  create_table "versions", force: :cascade do |t|
    t.datetime "created_at"
    t.string "event", null: false
    t.bigint "item_id", null: false
    t.string "item_type", null: false
    t.text "object"
    t.string "whodunnit"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  create_table "warehouses", force: :cascade do |t|
    t.boolean "active", default: true
    t.jsonb "address", default: {}
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.boolean "default_warehouse", default: false
    t.text "description"
    t.bigint "location_id"
    t.bigint "manager_id"
    t.string "name", null: false
    t.bigint "organization_id", null: false
    t.datetime "updated_at", null: false
    t.index ["location_id"], name: "index_warehouses_on_location_id"
    t.index ["manager_id"], name: "index_warehouses_on_manager_id"
    t.index ["organization_id", "code"], name: "index_warehouses_on_organization_id_and_code", unique: true
    t.index ["organization_id"], name: "index_warehouses_on_organization_id"
  end

  create_table "work_order_attachments", force: :cascade do |t|
    t.string "category"
    t.datetime "created_at", null: false
    t.string "description"
    t.string "file_name"
    t.string "file_type"
    t.datetime "updated_at", null: false
    t.bigint "uploaded_by_id", null: false
    t.bigint "work_order_id", null: false
    t.index ["uploaded_by_id"], name: "index_work_order_attachments_on_uploaded_by_id"
    t.index ["work_order_id"], name: "index_work_order_attachments_on_work_order_id"
  end

  create_table "work_order_checklist_items", force: :cascade do |t|
    t.string "actual_value"
    t.boolean "completed", default: false
    t.datetime "completed_at"
    t.bigint "completed_by_id"
    t.datetime "created_at", null: false
    t.text "description", null: false
    t.string "expected_value"
    t.text "notes"
    t.boolean "passed"
    t.integer "position", default: 0
    t.string "response_type", default: "checkbox"
    t.datetime "updated_at", null: false
    t.bigint "work_order_checklist_id", null: false
    t.index ["completed_by_id"], name: "index_work_order_checklist_items_on_completed_by_id"
    t.index ["work_order_checklist_id", "position"], name: "idx_on_work_order_checklist_id_position_8e36bc1b7c"
    t.index ["work_order_checklist_id"], name: "index_work_order_checklist_items_on_work_order_checklist_id"
  end

  create_table "work_order_checklists", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.integer "position", default: 0
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.bigint "work_order_id", null: false
    t.index ["work_order_id"], name: "index_work_order_checklists_on_work_order_id"
  end

  create_table "work_order_comments", force: :cascade do |t|
    t.string "comment_type", default: "comment"
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.boolean "internal", default: false
    t.jsonb "metadata", default: {}
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.bigint "work_order_id", null: false
    t.index ["user_id"], name: "index_work_order_comments_on_user_id"
    t.index ["work_order_id", "created_at"], name: "index_work_order_comments_on_work_order_id_and_created_at"
    t.index ["work_order_id"], name: "index_work_order_comments_on_work_order_id"
  end

  create_table "work_order_labors", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "end_time"
    t.decimal "hourly_rate", precision: 10, scale: 2
    t.decimal "hours", precision: 8, scale: 2
    t.text "notes"
    t.boolean "overtime", default: false
    t.decimal "overtime_multiplier", precision: 4, scale: 2, default: "1.5"
    t.datetime "start_time", null: false
    t.decimal "total_cost", precision: 15, scale: 2
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.bigint "work_order_id", null: false
    t.string "work_type"
    t.index ["user_id"], name: "index_work_order_labors_on_user_id"
    t.index ["work_order_id", "user_id"], name: "index_work_order_labors_on_work_order_id_and_user_id"
    t.index ["work_order_id"], name: "index_work_order_labors_on_work_order_id"
  end

  create_table "work_order_parts", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "issued_at"
    t.bigint "issued_by_id"
    t.bigint "part_id", null: false
    t.decimal "quantity_requested", precision: 10, scale: 2, null: false
    t.decimal "quantity_returned", precision: 10, scale: 2, default: "0.0"
    t.decimal "quantity_used", precision: 10, scale: 2, default: "0.0"
    t.datetime "requested_at"
    t.string "source"
    t.string "status", default: "requested"
    t.decimal "total_cost", precision: 15, scale: 2
    t.decimal "unit_cost", precision: 15, scale: 2
    t.datetime "updated_at", null: false
    t.bigint "work_order_id", null: false
    t.index ["issued_by_id"], name: "index_work_order_parts_on_issued_by_id"
    t.index ["part_id"], name: "index_work_order_parts_on_part_id"
    t.index ["work_order_id", "part_id"], name: "index_work_order_parts_on_work_order_id_and_part_id"
    t.index ["work_order_id"], name: "index_work_order_parts_on_work_order_id"
  end

  create_table "work_orders", force: :cascade do |t|
    t.decimal "actual_hours", precision: 8, scale: 2, default: "0.0"
    t.bigint "asset_id"
    t.bigint "assigned_to_id"
    t.string "category"
    t.bigint "cause_code_id"
    t.boolean "caused_downtime", default: false
    t.datetime "closed_at"
    t.bigint "closed_by_id"
    t.datetime "completed_at"
    t.text "completion_notes"
    t.integer "completion_percentage", default: 0
    t.datetime "created_at", null: false
    t.jsonb "custom_fields", default: {}
    t.text "description"
    t.datetime "discarded_at"
    t.datetime "downtime_end"
    t.decimal "downtime_hours", precision: 8, scale: 2
    t.datetime "downtime_start"
    t.datetime "due_date"
    t.decimal "estimated_hours", precision: 8, scale: 2
    t.decimal "estimated_labor_cost", precision: 15, scale: 2
    t.decimal "estimated_parts_cost", precision: 15, scale: 2
    t.decimal "estimated_total_cost", precision: 15, scale: 2
    t.decimal "external_cost", precision: 15, scale: 2, default: "0.0"
    t.text "failure_description"
    t.text "instructions"
    t.decimal "labor_cost", precision: 15, scale: 2, default: "0.0"
    t.bigint "location_id"
    t.string "number", null: false
    t.bigint "organization_id", null: false
    t.decimal "parts_cost", precision: 15, scale: 2, default: "0.0"
    t.datetime "paused_at"
    t.bigint "pm_occurrence_id"
    t.bigint "pm_schedule_id"
    t.string "priority", default: "medium"
    t.bigint "problem_code_id"
    t.bigint "remedy_code_id"
    t.datetime "requested_at"
    t.bigint "requester_id"
    t.text "root_cause_notes"
    t.text "safety_notes"
    t.datetime "scheduled_end"
    t.datetime "scheduled_start"
    t.boolean "sla_breached", default: false
    t.datetime "sla_due_at"
    t.string "source"
    t.datetime "started_at"
    t.string "status", default: "draft"
    t.bigint "supervisor_id"
    t.string "title", null: false
    t.decimal "total_cost", precision: 15, scale: 2, default: "0.0"
    t.datetime "updated_at", null: false
    t.text "verification_notes"
    t.datetime "verified_at"
    t.bigint "verified_by_id"
    t.string "work_order_type", null: false
    t.index ["asset_id"], name: "index_work_orders_on_asset_id"
    t.index ["assigned_to_id"], name: "index_work_orders_on_assigned_to_id"
    t.index ["cause_code_id"], name: "index_work_orders_on_cause_code_id"
    t.index ["closed_by_id"], name: "index_work_orders_on_closed_by_id"
    t.index ["discarded_at"], name: "index_work_orders_on_discarded_at"
    t.index ["location_id"], name: "index_work_orders_on_location_id"
    t.index ["organization_id", "asset_id"], name: "index_work_orders_on_organization_id_and_asset_id"
    t.index ["organization_id", "assigned_to_id"], name: "index_work_orders_on_organization_id_and_assigned_to_id"
    t.index ["organization_id", "due_date"], name: "index_work_orders_on_organization_id_and_due_date"
    t.index ["organization_id", "number"], name: "index_work_orders_on_organization_id_and_number", unique: true
    t.index ["organization_id", "priority"], name: "index_work_orders_on_organization_id_and_priority"
    t.index ["organization_id", "status"], name: "index_work_orders_on_organization_id_and_status"
    t.index ["organization_id", "work_order_type"], name: "index_work_orders_on_organization_id_and_work_order_type"
    t.index ["organization_id"], name: "index_work_orders_on_organization_id"
    t.index ["pm_schedule_id"], name: "index_work_orders_on_pm_schedule_id"
    t.index ["problem_code_id"], name: "index_work_orders_on_problem_code_id"
    t.index ["remedy_code_id"], name: "index_work_orders_on_remedy_code_id"
    t.index ["requester_id"], name: "index_work_orders_on_requester_id"
    t.index ["sla_breached"], name: "index_work_orders_on_sla_breached"
    t.index ["supervisor_id"], name: "index_work_orders_on_supervisor_id"
    t.index ["verified_by_id"], name: "index_work_orders_on_verified_by_id"
  end

  add_foreign_key "asset_categories", "asset_categories", column: "parent_id"
  add_foreign_key "asset_categories", "organizations"
  add_foreign_key "asset_parts", "assets"
  add_foreign_key "asset_parts", "parts"
  add_foreign_key "asset_transfers", "assets"
  add_foreign_key "asset_transfers", "locations", column: "from_location_id"
  add_foreign_key "asset_transfers", "locations", column: "to_location_id"
  add_foreign_key "asset_transfers", "users", column: "approved_by_id"
  add_foreign_key "asset_transfers", "users", column: "transferred_by_id"
  add_foreign_key "assets", "asset_categories"
  add_foreign_key "assets", "assets", column: "parent_id"
  add_foreign_key "assets", "locations"
  add_foreign_key "assets", "organizations"
  add_foreign_key "failure_codes", "failure_codes", column: "parent_id"
  add_foreign_key "failure_codes", "organizations"
  add_foreign_key "goods_receipt_items", "goods_receipts"
  add_foreign_key "goods_receipt_items", "parts"
  add_foreign_key "goods_receipt_items", "purchase_requisition_items"
  add_foreign_key "goods_receipt_items", "stock_locations"
  add_foreign_key "goods_receipts", "organizations"
  add_foreign_key "goods_receipts", "purchase_requisitions"
  add_foreign_key "goods_receipts", "suppliers"
  add_foreign_key "goods_receipts", "users", column: "received_by_id"
  add_foreign_key "goods_receipts", "warehouses"
  add_foreign_key "inspection_items", "inspections"
  add_foreign_key "inspections", "assets"
  add_foreign_key "inspections", "organizations"
  add_foreign_key "inspections", "users", column: "inspector_id"
  add_foreign_key "inspections", "work_orders"
  add_foreign_key "inventory_items", "parts"
  add_foreign_key "inventory_items", "stock_locations"
  add_foreign_key "locations", "locations", column: "parent_id"
  add_foreign_key "locations", "organizations"
  add_foreign_key "meter_readings", "assets"
  add_foreign_key "meter_readings", "users", column: "recorded_by_id"
  add_foreign_key "meter_readings", "work_orders"
  add_foreign_key "notifications", "organizations"
  add_foreign_key "notifications", "users", column: "actor_id"
  add_foreign_key "notifications", "users", column: "recipient_id"
  add_foreign_key "part_categories", "organizations"
  add_foreign_key "part_categories", "part_categories", column: "parent_id"
  add_foreign_key "parts", "organizations"
  add_foreign_key "parts", "part_categories"
  add_foreign_key "parts", "stock_locations", column: "default_stock_location_id"
  add_foreign_key "parts", "suppliers", column: "preferred_supplier_id"
  add_foreign_key "pm_occurrences", "preventive_maintenance_schedules"
  add_foreign_key "pm_occurrences", "users", column: "skipped_by_id"
  add_foreign_key "pm_occurrences", "work_orders"
  add_foreign_key "pm_templates", "asset_categories"
  add_foreign_key "pm_templates", "organizations"
  add_foreign_key "preventive_maintenance_schedules", "assets"
  add_foreign_key "preventive_maintenance_schedules", "locations"
  add_foreign_key "preventive_maintenance_schedules", "organizations"
  add_foreign_key "preventive_maintenance_schedules", "pm_templates"
  add_foreign_key "preventive_maintenance_schedules", "users", column: "default_assignee_id"
  add_foreign_key "preventive_maintenance_schedules", "users", column: "escalation_contact_id"
  add_foreign_key "purchase_requisition_items", "parts"
  add_foreign_key "purchase_requisition_items", "purchase_requisitions"
  add_foreign_key "purchase_requisitions", "organizations"
  add_foreign_key "purchase_requisitions", "suppliers"
  add_foreign_key "purchase_requisitions", "users", column: "approved_by_id"
  add_foreign_key "purchase_requisitions", "users", column: "requested_by_id"
  add_foreign_key "purchase_requisitions", "warehouses"
  add_foreign_key "purchase_requisitions", "work_orders"
  add_foreign_key "roles", "organizations"
  add_foreign_key "stock_locations", "warehouses"
  add_foreign_key "stock_movements", "parts"
  add_foreign_key "stock_movements", "purchase_requisitions"
  add_foreign_key "stock_movements", "stock_locations"
  add_foreign_key "stock_movements", "stock_locations", column: "destination_location_id"
  add_foreign_key "stock_movements", "users"
  add_foreign_key "stock_movements", "work_orders"
  add_foreign_key "suppliers", "organizations"
  add_foreign_key "user_roles", "roles"
  add_foreign_key "user_roles", "users"
  add_foreign_key "user_roles", "users", column: "assigned_by_id"
  add_foreign_key "users", "organizations"
  add_foreign_key "warehouses", "locations"
  add_foreign_key "warehouses", "organizations"
  add_foreign_key "warehouses", "users", column: "manager_id"
  add_foreign_key "work_order_attachments", "users", column: "uploaded_by_id"
  add_foreign_key "work_order_attachments", "work_orders"
  add_foreign_key "work_order_checklist_items", "users", column: "completed_by_id"
  add_foreign_key "work_order_checklist_items", "work_order_checklists"
  add_foreign_key "work_order_checklists", "work_orders"
  add_foreign_key "work_order_comments", "users"
  add_foreign_key "work_order_comments", "work_orders"
  add_foreign_key "work_order_labors", "users"
  add_foreign_key "work_order_labors", "work_orders"
  add_foreign_key "work_order_parts", "parts"
  add_foreign_key "work_order_parts", "users", column: "issued_by_id"
  add_foreign_key "work_order_parts", "work_orders"
  add_foreign_key "work_orders", "assets"
  add_foreign_key "work_orders", "failure_codes", column: "cause_code_id"
  add_foreign_key "work_orders", "failure_codes", column: "problem_code_id"
  add_foreign_key "work_orders", "failure_codes", column: "remedy_code_id"
  add_foreign_key "work_orders", "locations"
  add_foreign_key "work_orders", "organizations"
  add_foreign_key "work_orders", "pm_occurrences"
  add_foreign_key "work_orders", "preventive_maintenance_schedules", column: "pm_schedule_id"
  add_foreign_key "work_orders", "users", column: "assigned_to_id"
  add_foreign_key "work_orders", "users", column: "closed_by_id"
  add_foreign_key "work_orders", "users", column: "requester_id"
  add_foreign_key "work_orders", "users", column: "supervisor_id"
  add_foreign_key "work_orders", "users", column: "verified_by_id"
end

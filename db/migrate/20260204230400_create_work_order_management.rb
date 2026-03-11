# frozen_string_literal: true

class CreateWorkOrderManagement < ActiveRecord::Migration[8.0]
  def change
    # =======================================================================
    # Failure Codes (Problem → Cause → Remedy hierarchy)
    # =======================================================================
    create_table :failure_codes do |t|
      t.references :organization, null: false, foreign_key: true
      t.references :parent, foreign_key: { to_table: :failure_codes }

      t.string :code, null: false
      t.string :name, null: false
      t.string :code_type, null: false  # problem, cause, remedy
      t.text :description
      t.boolean :active, default: true

      t.timestamps
    end

    add_index :failure_codes, [ :organization_id, :code ], unique: true
    add_index :failure_codes, [ :organization_id, :code_type ]
    add_index :failure_codes, [ :organization_id, :parent_id ]

    # =======================================================================
    # Work Orders
    # =======================================================================
    create_table :work_orders do |t|
      t.references :organization, null: false, foreign_key: true
      t.references :asset, foreign_key: true
      t.references :location, foreign_key: true

      # =======================================================================
      # Identification
      # =======================================================================
      t.string :number, null: false

      # =======================================================================
      # Type & Priority
      # =======================================================================
      t.string :work_order_type, null: false  # corrective, preventive, predictive, emergency, inspection
      t.string :priority, default: 'medium'   # critical, high, medium, low
      t.string :category  # electrical, mechanical, plumbing, hvac, general

      # =======================================================================
      # Status (managed by AASM state machine)
      # =======================================================================
      t.string :status, default: 'draft'
      # States: draft → open → assigned → in_progress → on_hold → completed → verified → closed → cancelled

      # =======================================================================
      # Description
      # =======================================================================
      t.string :title, null: false
      t.text :description
      t.text :instructions
      t.text :safety_notes

      # =======================================================================
      # Scheduling
      # =======================================================================
      t.datetime :requested_at
      t.datetime :scheduled_start
      t.datetime :scheduled_end
      t.datetime :due_date

      # =======================================================================
      # Actual Execution Times
      # =======================================================================
      t.datetime :started_at
      t.datetime :paused_at
      t.datetime :completed_at
      t.datetime :verified_at
      t.datetime :closed_at

      # =======================================================================
      # People
      # =======================================================================
      t.references :requester, foreign_key: { to_table: :users }
      t.references :assigned_to, foreign_key: { to_table: :users }
      t.references :supervisor, foreign_key: { to_table: :users }
      t.references :verified_by, foreign_key: { to_table: :users }
      t.references :closed_by, foreign_key: { to_table: :users }

      # =======================================================================
      # Root Cause Analysis
      # =======================================================================
      t.references :problem_code, foreign_key: { to_table: :failure_codes }
      t.references :cause_code, foreign_key: { to_table: :failure_codes }
      t.references :remedy_code, foreign_key: { to_table: :failure_codes }
      t.text :root_cause_notes
      t.text :failure_description

      # =======================================================================
      # Labor & Cost Estimates
      # =======================================================================
      t.decimal :estimated_hours, precision: 8, scale: 2
      t.decimal :actual_hours, precision: 8, scale: 2, default: 0

      t.decimal :estimated_labor_cost, precision: 15, scale: 2
      t.decimal :estimated_parts_cost, precision: 15, scale: 2
      t.decimal :estimated_total_cost, precision: 15, scale: 2

      t.decimal :labor_cost, precision: 15, scale: 2, default: 0
      t.decimal :parts_cost, precision: 15, scale: 2, default: 0
      t.decimal :external_cost, precision: 15, scale: 2, default: 0
      t.decimal :total_cost, precision: 15, scale: 2, default: 0

      # =======================================================================
      # Downtime Tracking
      # =======================================================================
      t.datetime :downtime_start
      t.datetime :downtime_end
      t.decimal :downtime_hours, precision: 8, scale: 2
      t.boolean :caused_downtime, default: false

      # =======================================================================
      # Completion Info
      # =======================================================================
      t.text :completion_notes
      t.text :verification_notes
      t.integer :completion_percentage, default: 0

      # =======================================================================
      # PM Reference (if generated from PM schedule)
      # =======================================================================
      t.bigint :pm_schedule_id
      t.bigint :pm_occurrence_id

      # =======================================================================
      # Metadata
      # =======================================================================
      t.jsonb :custom_fields, default: {}
      t.string :source  # manual, pm_generated, iot_triggered, api

      # =======================================================================
      # SLA Tracking
      # =======================================================================
      t.datetime :sla_due_at
      t.boolean :sla_breached, default: false

      t.timestamps
    end

    # Indexes for common queries
    add_index :work_orders, [ :organization_id, :number ], unique: true
    add_index :work_orders, [ :organization_id, :status ]
    add_index :work_orders, [ :organization_id, :work_order_type ]
    add_index :work_orders, [ :organization_id, :priority ]
    add_index :work_orders, [ :organization_id, :due_date ]
    add_index :work_orders, [ :organization_id, :assigned_to_id ]
    add_index :work_orders, [ :organization_id, :asset_id ]
    add_index :work_orders, :pm_schedule_id
    add_index :work_orders, :sla_breached

    # =======================================================================
    # Work Order Labor Entries
    # =======================================================================
    create_table :work_order_labors do |t|
      t.references :work_order, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.datetime :start_time, null: false
      t.datetime :end_time
      t.decimal :hours, precision: 8, scale: 2
      t.decimal :hourly_rate, precision: 10, scale: 2
      t.decimal :total_cost, precision: 15, scale: 2

      t.boolean :overtime, default: false
      t.decimal :overtime_multiplier, precision: 4, scale: 2, default: 1.5

      t.string :work_type  # repair, inspection, cleaning, setup
      t.text :notes

      t.timestamps
    end

    add_index :work_order_labors, [ :work_order_id, :user_id ]

    # =======================================================================
    # Work Order Parts Used
    # =======================================================================
    create_table :work_order_parts do |t|
      t.references :work_order, null: false, foreign_key: true
      t.references :part, null: false, foreign_key: true
      t.references :issued_by, foreign_key: { to_table: :users }

      t.decimal :quantity_requested, precision: 10, scale: 2, null: false
      t.decimal :quantity_used, precision: 10, scale: 2, default: 0
      t.decimal :quantity_returned, precision: 10, scale: 2, default: 0

      t.decimal :unit_cost, precision: 15, scale: 2
      t.decimal :total_cost, precision: 15, scale: 2

      t.string :source  # stock, purchase, reserved
      t.string :status, default: 'requested'  # requested, reserved, issued, used, returned

      t.datetime :requested_at
      t.datetime :issued_at

      t.timestamps
    end

    add_index :work_order_parts, [ :work_order_id, :part_id ]

    # =======================================================================
    # Work Order Checklists
    # =======================================================================
    create_table :work_order_checklists do |t|
      t.references :work_order, null: false, foreign_key: true

      t.string :title, null: false
      t.text :description
      t.integer :position, default: 0

      t.timestamps
    end

    create_table :work_order_checklist_items do |t|
      t.references :work_order_checklist, null: false, foreign_key: true
      t.references :completed_by, foreign_key: { to_table: :users }

      t.text :description, null: false
      t.string :response_type, default: 'checkbox'  # checkbox, yes_no, numeric, text
      t.string :expected_value
      t.string :actual_value

      t.boolean :completed, default: false
      t.boolean :passed  # For pass/fail items
      t.datetime :completed_at

      t.integer :position, default: 0
      t.text :notes

      t.timestamps
    end

    add_index :work_order_checklist_items, [ :work_order_checklist_id, :position ]

    # =======================================================================
    # Work Order Comments / Activity Log
    # =======================================================================
    create_table :work_order_comments do |t|
      t.references :work_order, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.text :content, null: false
      t.string :comment_type, default: 'comment'  # comment, status_change, assignment, note
      t.boolean :internal, default: false  # Internal notes visible only to supervisors

      t.jsonb :metadata, default: {}  # For status changes, store old/new values

      t.timestamps
    end

    add_index :work_order_comments, [ :work_order_id, :created_at ]

    # =======================================================================
    # Work Order Attachments (using Active Storage, this is metadata)
    # =======================================================================
    create_table :work_order_attachments do |t|
      t.references :work_order, null: false, foreign_key: true
      t.references :uploaded_by, null: false, foreign_key: { to_table: :users }

      t.string :file_name
      t.string :file_type  # image, document, video
      t.string :description
      t.string :category  # before, after, safety, documentation

      t.timestamps
    end
  end
end

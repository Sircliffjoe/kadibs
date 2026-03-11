# frozen_string_literal: true

class CreatePreventiveMaintenance < ActiveRecord::Migration[8.0]
  def change
    # =======================================================================
    # PM Templates (Reusable task definitions)
    # =======================================================================
    create_table :pm_templates do |t|
      t.references :organization, null: false, foreign_key: true
      t.references :asset_category, foreign_key: true

      t.string :name, null: false
      t.string :code
      t.text :description

      # Estimates
      t.decimal :estimated_hours, precision: 8, scale: 2
      t.decimal :estimated_cost, precision: 15, scale: 2

      # Task definitions stored as JSON array
      # Format: [{ "description": "Check oil level", "response_type": "pass_fail" }, ...]
      t.jsonb :tasks, default: []

      # Required skills for this PM
      t.jsonb :required_skills, default: []

      # Required parts (with quantities)
      # Format: [{ "part_id": 1, "quantity": 2 }, ...]
      t.jsonb :required_parts, default: []

      # Safety requirements
      t.jsonb :safety_requirements, default: []

      t.boolean :active, default: true

      t.timestamps
    end

    add_index :pm_templates, [ :organization_id, :code ], unique: true, where: "code IS NOT NULL"
    add_index :pm_templates, [ :organization_id, :name ]

    # =======================================================================
    # Preventive Maintenance Schedules
    # =======================================================================
    create_table :preventive_maintenance_schedules do |t|
      t.references :organization, null: false, foreign_key: true
      t.references :asset, null: false, foreign_key: true
      t.references :pm_template, foreign_key: true
      t.references :location, foreign_key: true

      # =======================================================================
      # Basic Info
      # =======================================================================
      t.string :name, null: false
      t.string :code
      t.text :description
      t.string :schedule_type, null: false  # time_based, meter_based, both
      t.boolean :active, default: true

      # =======================================================================
      # Time-Based Scheduling
      # =======================================================================
      t.string :frequency_unit  # days, weeks, months, years
      t.integer :frequency_value
      t.date :start_date
      t.date :end_date  # Optional end date for the schedule

      t.date :last_generated_date
      t.date :next_due_date

      # Specific day/time preferences
      t.integer :preferred_day_of_week  # 0=Sunday, 6=Saturday
      t.integer :preferred_day_of_month
      t.time :preferred_time

      # =======================================================================
      # Meter-Based Scheduling
      # =======================================================================
      t.string :meter_type  # hours, km, miles, cycles
      t.decimal :meter_interval, precision: 15, scale: 2
      t.decimal :last_meter_reading, precision: 15, scale: 2
      t.decimal :next_meter_due, precision: 15, scale: 2
      t.decimal :meter_warning_threshold, precision: 15, scale: 2  # Alert when close to due

      # =======================================================================
      # Work Order Defaults
      # =======================================================================
      t.string :priority, default: 'medium'
      t.string :work_order_type, default: 'preventive'
      t.references :default_assignee, foreign_key: { to_table: :users }
      t.decimal :estimated_hours, precision: 8, scale: 2
      t.decimal :estimated_cost, precision: 15, scale: 2

      t.text :instructions
      t.text :safety_notes

      # Checklist template for generated WOs
      t.jsonb :checklist_template, default: []

      # Required parts template
      t.jsonb :parts_template, default: []

      # =======================================================================
      # Lead Time & Notifications
      # =======================================================================
      t.integer :lead_time_days, default: 7  # Days before due to create WO
      t.integer :notification_days, default: 3  # Days before to send reminder

      # =======================================================================
      # Escalation
      # =======================================================================
      t.integer :escalation_days  # Days after due date to escalate
      t.references :escalation_contact, foreign_key: { to_table: :users }

      # =======================================================================
      # Statistics
      # =======================================================================
      t.integer :total_occurrences, default: 0
      t.integer :completed_occurrences, default: 0
      t.integer :missed_occurrences, default: 0
      t.decimal :compliance_rate, precision: 5, scale: 2, default: 100

      t.date :last_completed_date

      # =======================================================================
      # Seasonal Schedule (optional)
      # =======================================================================
      t.jsonb :seasonal_months, default: []  # e.g., [3, 6, 9, 12] for quarterly
      t.boolean :skip_weekends, default: false
      t.boolean :skip_holidays, default: false

      t.timestamps
    end

    add_index :preventive_maintenance_schedules, [ :organization_id, :asset_id ]
    add_index :preventive_maintenance_schedules, [ :organization_id, :next_due_date ]
    add_index :preventive_maintenance_schedules, [ :organization_id, :active ]
    add_index :preventive_maintenance_schedules, :next_meter_due, where: "meter_type IS NOT NULL"

    # =======================================================================
    # PM Occurrences (Track each instance of a PM)
    # =======================================================================
    create_table :pm_occurrences do |t|
      t.references :preventive_maintenance_schedule, null: false, foreign_key: true
      t.references :work_order, foreign_key: true

      t.date :scheduled_date, null: false
      t.decimal :scheduled_meter_reading, precision: 15, scale: 2

      t.string :status, default: 'scheduled'  # scheduled, generated, completed, missed, skipped

      t.date :completed_date
      t.decimal :actual_meter_reading, precision: 15, scale: 2

      t.text :skip_reason  # If skipped
      t.references :skipped_by, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :pm_occurrences, [ :preventive_maintenance_schedule_id, :scheduled_date ]
    add_index :pm_occurrences, [ :preventive_maintenance_schedule_id, :status ]

    # =======================================================================
    # Add PM reference to work_orders table
    # =======================================================================
    add_foreign_key :work_orders, :preventive_maintenance_schedules, column: :pm_schedule_id
    add_foreign_key :work_orders, :pm_occurrences, column: :pm_occurrence_id
  end
end

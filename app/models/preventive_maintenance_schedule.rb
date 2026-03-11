# frozen_string_literal: true

class PreventiveMaintenanceSchedule < ApplicationRecord
  include PgSearch::Model

  has_paper_trail

  # ===========================================================================
  # Associations
  # ===========================================================================
  belongs_to :organization
  belongs_to :asset
  belongs_to :pm_template, optional: true
  belongs_to :location, optional: true
  belongs_to :default_assignee, class_name: "User", optional: true
  belongs_to :escalation_contact, class_name: "User", optional: true

  has_many :pm_occurrences, dependent: :destroy
  has_many :work_orders, dependent: :nullify

  # ===========================================================================
  # Tenant Scoping
  # ===========================================================================

  # ===========================================================================
  # Scopes
  # ===========================================================================
  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }
  scope :time_based, -> { where(schedule_type: "time_based") }
  scope :meter_based, -> { where(schedule_type: "meter_based") }
  scope :due_within, ->(days) { where("next_due_date <= ?", days.days.from_now) }
  scope :overdue, -> { where("next_due_date < ?", Date.current) }
  scope :for_asset, ->(asset_id) { where(asset_id: asset_id) }

  # ===========================================================================
  # Validations
  # ===========================================================================
  SCHEDULE_TYPES = %w[time_based meter_based both].freeze
  FREQUENCY_UNITS = %w[days weeks months years].freeze
  PRIORITIES = %w[critical high medium low].freeze

  validates :name, presence: true
  validates :schedule_type, presence: true, inclusion: { in: SCHEDULE_TYPES }
  validates :frequency_unit, inclusion: { in: FREQUENCY_UNITS }, allow_blank: true
  validates :frequency_value, numericality: { greater_than: 0 }, allow_nil: true
  validates :priority, inclusion: { in: PRIORITIES }

  validates :frequency_unit, :frequency_value, presence: true,
            if: -> { %w[time_based both].include?(schedule_type) }
  validates :meter_type, :meter_interval, presence: true,
            if: -> { %w[meter_based both].include?(schedule_type) }

  # ===========================================================================
  # Callbacks
  # ===========================================================================
  before_create :set_next_due_date
  after_create :create_initial_occurrence

  # ===========================================================================
  # Instance Methods
  # ===========================================================================
  def due?
    return false unless active?

    if time_based? || both?
      return true if next_due_date.present? && next_due_date <= Date.current
    end

    if meter_based? || both?
      current_reading = asset&.meter_reading
      return true if next_meter_due.present? && current_reading.present? && current_reading >= next_meter_due
    end

    false
  end

  def overdue?
    return false unless active?

    if time_based? || both?
      return true if next_due_date.present? && next_due_date < Date.current
    end

    false
  end

  def days_until_due
    return nil unless next_due_date.present?
    (next_due_date - Date.current).to_i
  end

  def time_based?
    schedule_type == "time_based"
  end

  def meter_based?
    schedule_type == "meter_based"
  end

  def both?
    schedule_type == "both"
  end

  def generate_work_order!(user: nil)
    transaction do
      wo = WorkOrder.create!(
        organization: organization,
        asset: asset,
        location: location || asset.location,
        title: name,
        description: description,
        instructions: instructions,
        safety_notes: safety_notes,
        work_order_type: work_order_type || "preventive",
        priority: priority,
        assigned_to: default_assignee,
        estimated_hours: estimated_hours,
        pm_schedule: self,
        source: "pm_generated",
        due_date: next_due_date || Date.current
      )

      # Create checklist from template
      if checklist_template.present?
        checklist = wo.work_order_checklists.create!(
          title: "#{name} Checklist"
        )
        checklist_template.each_with_index do |item, index|
          checklist.work_order_checklist_items.create!(
            description: item["description"],
            response_type: item["response_type"] || "checkbox",
            position: index
          )
        end
      end

      # Create part requirements from template
      if parts_template.present?
        parts_template.each do |pt|
          part = Part.find_by(id: pt["part_id"])
          next unless part
          wo.work_order_parts.create!(
            part: part,
            quantity_requested: pt["quantity"] || 1,
            unit_cost: part.unit_cost,
            requested_at: Time.current
          )
        end
      end

      # Create occurrence record
      occurrence = pm_occurrences.create!(
        work_order: wo,
        scheduled_date: next_due_date || Date.current,
        scheduled_meter_reading: next_meter_due,
        status: "generated"
      )

      wo.update!(pm_occurrence: occurrence)

      # Update schedule
      update!(
        last_generated_date: Date.current,
        total_occurrences: total_occurrences + 1
      )
      calculate_next_due!

      wo
    end
  end

  def calculate_next_due!
    if time_based? || both?
      next_date = case frequency_unit
      when "days" then (next_due_date || Date.current) + frequency_value.days
      when "weeks" then (next_due_date || Date.current) + frequency_value.weeks
      when "months" then (next_due_date || Date.current) + frequency_value.months
      when "years" then (next_due_date || Date.current) + frequency_value.years
      end

      # Apply preferred day of week/month if set
      if preferred_day_of_week.present?
        next_date = next_date.beginning_of_week + preferred_day_of_week.days
      end

      # Skip weekends if configured
      if skip_weekends
        next_date += 1.day while next_date.saturday? || next_date.sunday?
      end

      update!(next_due_date: next_date)
    end

    if meter_based? || both?
      current_reading = asset&.meter_reading || 0
      update!(
        last_meter_reading: current_reading,
        next_meter_due: current_reading + meter_interval
      )
    end
  end

  def update_compliance_rate!
    completed = pm_occurrences.where(status: "completed").count
    missed = pm_occurrences.where(status: "missed").count
    total = completed + missed

    rate = total.positive? ? (completed.to_f / total * 100) : 100
    update!(
      completed_occurrences: completed,
      missed_occurrences: missed,
      compliance_rate: rate.round(2)
    )
  end

  def activate!
    update!(active: true)
  end

  def deactivate!
    update!(active: false)
  end

  private

  def set_next_due_date
    if time_based? || both?
      self.next_due_date ||= start_date || Date.current
    end

    if meter_based? || both?
      current_reading = asset&.meter_reading || 0
      self.next_meter_due ||= current_reading + (meter_interval || 0)
    end
  end

  def create_initial_occurrence
    return unless next_due_date.present?

    pm_occurrences.create!(
      scheduled_date: next_due_date,
      scheduled_meter_reading: next_meter_due,
      status: "scheduled"
    )
  end
end

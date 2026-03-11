# frozen_string_literal: true

class WorkOrder < ApplicationRecord
  include AASM
  include Discard::Model
  include PgSearch::Model

  has_paper_trail

  # ===========================================================================
  # Associations
  # ===========================================================================
  belongs_to :organization
  belongs_to :asset, optional: true
  belongs_to :location, optional: true

  # People
  belongs_to :requester, class_name: "User", optional: true
  belongs_to :assigned_to, class_name: "User", optional: true
  belongs_to :supervisor, class_name: "User", optional: true
  belongs_to :verified_by, class_name: "User", optional: true
  belongs_to :closed_by, class_name: "User", optional: true

  # Failure codes
  belongs_to :problem_code, class_name: "FailureCode", optional: true
  belongs_to :cause_code, class_name: "FailureCode", optional: true
  belongs_to :remedy_code, class_name: "FailureCode", optional: true

  # PM References
  belongs_to :pm_schedule, class_name: "PreventiveMaintenanceSchedule", optional: true
  belongs_to :pm_occurrence, class_name: "PmOccurrence", optional: true

  # Children
  has_many :work_order_labors, dependent: :destroy
  has_many :work_order_parts, dependent: :destroy
  has_many :work_order_checklists, dependent: :destroy
  has_many :work_order_comments, dependent: :destroy
  has_many :work_order_attachments, dependent: :destroy
  has_many :meter_readings, dependent: :nullify
  has_many :stock_movements, dependent: :nullify
  has_many :purchase_requisitions, dependent: :nullify

  has_many_attached :attachments

  # ===========================================================================
  # Tenant Scoping
  # ===========================================================================
  default_scope -> { kept }

  # ===========================================================================
  # Full-Text Search
  # ===========================================================================
  pg_search_scope :search_all,
                  against: [ :number, :title, :description ],
                  using: { tsearch: { prefix: true, dictionary: "english" } }

  # ===========================================================================
  # AASM State Machine
  # ===========================================================================
  aasm column: :status, whiny_transitions: true do
    state :draft, initial: true
    state :open
    state :assigned
    state :in_progress
    state :on_hold
    state :completed
    state :verified
    state :closed
    state :cancelled

    event :submit, after: :set_requested_at do
      transitions from: :draft, to: :open
    end

    event :assign, after: :notify_assignee do
      transitions from: [ :open, :assigned ], to: :assigned, guard: :has_assignee?
    end

    event :start, after: :set_started_at do
      transitions from: [ :open, :assigned ], to: :in_progress
    end

    event :pause do
      transitions from: :in_progress, to: :on_hold, after: :set_paused_at
    end

    event :resume do
      transitions from: :on_hold, to: :in_progress
    end

    event :complete, after: :set_completed_at do
      transitions from: [ :in_progress, :assigned ], to: :completed
    end

    event :verify, after: :set_verified_at do
      transitions from: :completed, to: :verified, guard: :has_verifier?
    end

    event :close, after: :set_closed_at do
      transitions from: [ :completed, :verified ], to: :closed
    end

    event :reopen do
      transitions from: [ :completed, :verified, :closed ], to: :open
    end

    event :cancel do
      transitions from: [ :draft, :open, :assigned, :in_progress, :on_hold ], to: :cancelled
    end
  end

  # ===========================================================================
  # Scopes
  # ===========================================================================
  scope :active, -> { where(status: %w[open assigned in_progress on_hold]) }
  scope :overdue, -> { active.where("due_date < ?", Date.current) }
  scope :due_today, -> { active.where(due_date: Date.current.all_day) }
  scope :due_this_week, -> { active.where(due_date: Date.current.beginning_of_week..Date.current.end_of_week) }

  scope :by_type, ->(type) { where(work_order_type: type) }
  scope :corrective, -> { by_type("corrective") }
  scope :preventive, -> { by_type("preventive") }
  scope :emergency, -> { by_type("emergency") }

  scope :by_priority, ->(priority) { where(priority: priority) }
  scope :critical_priority, -> { by_priority("critical") }
  scope :high_priority, -> { by_priority("high") }

  scope :for_technician, ->(user_id) { where(assigned_to_id: user_id) }
  scope :for_asset, ->(asset_id) { where(asset_id: asset_id) }

  scope :completed_between, ->(start_date, end_date) {
    where(completed_at: start_date..end_date)
  }

  scope :sla_breached, -> { where(sla_breached: true) }

  # ===========================================================================
  # Validations
  # ===========================================================================
  TYPES = %w[corrective preventive predictive emergency inspection calibration].freeze
  PRIORITIES = %w[critical high medium low].freeze
  CATEGORIES = %w[electrical mechanical plumbing hvac general safety it].freeze

  validates :number, presence: true, uniqueness: { scope: :organization_id }
  validates :title, presence: true
  validates :work_order_type, presence: true, inclusion: { in: TYPES }
  validates :priority, inclusion: { in: PRIORITIES }
  validates :category, inclusion: { in: CATEGORIES }, allow_blank: true

  # ===========================================================================
  # Callbacks
  # ===========================================================================
  before_validation :generate_number, on: :create
  before_save :calculate_costs
  before_save :check_sla_breach
  after_save :update_asset_maintenance_date, if: -> { saved_change_to_status? && closed? }

  # ===========================================================================
  # Instance Methods
  # ===========================================================================
  def overdue?
    due_date.present? && due_date < Date.current && active?
  end

  def active?
    %w[open assigned in_progress on_hold].include?(status)
  end

  def completion_time_hours
    return nil unless started_at.present? && completed_at.present?
    ((completed_at - started_at) / 1.hour).round(2)
  end

  def response_time_hours
    return nil unless requested_at.present? && started_at.present?
    ((started_at - requested_at) / 1.hour).round(2)
  end

  def add_labor!(user:, start_time:, end_time: nil, hourly_rate: nil, notes: nil)
    work_order_labors.create!(
      user: user,
      start_time: start_time,
      end_time: end_time,
      hourly_rate: hourly_rate || user.hourly_rate,
      notes: notes
    )
    recalculate_labor_cost!
  end

  def add_part!(part:, quantity:, issued_by: nil)
    wop = work_order_parts.create!(
      part: part,
      quantity_requested: quantity,
      unit_cost: part.unit_cost,
      issued_by: issued_by,
      requested_at: Time.current
    )
    recalculate_parts_cost!
    wop
  end

  def add_comment!(user:, content:, internal: false)
    work_order_comments.create!(
      user: user,
      content: content,
      internal: internal,
      comment_type: "comment"
    )
  end

  def log_status_change!(user:, from_status:, to_status:)
    work_order_comments.create!(
      user: user,
      content: "Status changed from #{from_status} to #{to_status}",
      comment_type: "status_change",
      internal: false,
      metadata: { from: from_status, to: to_status }
    )
  end

  def recalculate_labor_cost!
    total = work_order_labors.sum(:total_cost)
    update_column(:labor_cost, total)
    recalculate_total_cost!
  end

  def recalculate_parts_cost!
    total = work_order_parts.sum(:total_cost)
    update_column(:parts_cost, total)
    recalculate_total_cost!
  end

  def recalculate_total_cost!
    update_column(:total_cost, labor_cost.to_f + parts_cost.to_f + external_cost.to_f)
  end

  private

  def generate_number
    return if number.present?

    prefix = case work_order_type
    when "preventive" then "PM"
    when "corrective" then "CM"
    when "emergency" then "EM"
    else "WO"
    end

    last_number = organization.work_orders.maximum(:number)&.gsub(/\D/, "")&.to_i || 0
    self.number = "#{prefix}-#{(last_number + 1).to_s.rjust(6, '0')}"
  end

  def calculate_costs
    self.actual_hours = work_order_labors.sum(:hours)
  end

  def check_sla_breach
    return unless sla_due_at.present? && !sla_breached?
    self.sla_breached = Time.current > sla_due_at
  end

  def update_asset_maintenance_date
    return unless asset.present?
    asset.update(last_maintenance_date: completed_at&.to_date || Date.current)
  end

  def has_assignee?
    assigned_to.present?
  end

  def has_verifier?
    verified_by.present?
  end

  def set_requested_at
    update_column(:requested_at, Time.current) if requested_at.blank?
  end

  def set_started_at
    update_column(:started_at, Time.current)
  end

  def set_paused_at
    update_column(:paused_at, Time.current)
  end

  def set_completed_at
    update_column(:completed_at, Time.current)
  end

  def set_verified_at
    update_column(:verified_at, Time.current)
  end

  def set_closed_at
    update_column(:closed_at, Time.current)
  end

  def notify_assignee
    # TODO: Send notification to assigned technician
  end
end

# frozen_string_literal: true

class PmOccurrence < ApplicationRecord
  belongs_to :preventive_maintenance_schedule
  belongs_to :work_order, optional: true
  belongs_to :skipped_by, class_name: "User", optional: true

  validates :scheduled_date, presence: true

  scope :scheduled, -> { where(status: "scheduled") }
  scope :generated, -> { where(status: "generated") }
  scope :completed, -> { where(status: "completed") }
  scope :missed, -> { where(status: "missed") }
  scope :skipped, -> { where(status: "skipped") }

  def complete!(actual_meter_reading: nil)
    update!(
      status: "completed",
      completed_date: Date.current,
      actual_meter_reading: actual_meter_reading
    )
    preventive_maintenance_schedule.update_compliance_rate!
  end

  def skip!(user, reason)
    update!(
      status: "skipped",
      skipped_by: user,
      skip_reason: reason
    )
    preventive_maintenance_schedule.update_compliance_rate!
  end

  def mark_missed!
    update!(status: "missed")
    preventive_maintenance_schedule.update_compliance_rate!
  end
end

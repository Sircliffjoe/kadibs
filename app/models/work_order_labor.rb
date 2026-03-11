# frozen_string_literal: true

class WorkOrderLabor < ApplicationRecord
  has_paper_trail

  belongs_to :work_order
  belongs_to :user

  validates :start_time, presence: true
  validates :hours, numericality: { greater_than: 0 }, allow_nil: true

  before_save :calculate_hours_and_cost

  private

  def calculate_hours_and_cost
    if start_time.present? && end_time.present?
      self.hours ||= ((end_time - start_time) / 1.hour).round(2)
    end

    if hours.present? && hourly_rate.present?
      multiplier = overtime? ? (overtime_multiplier || 1.5) : 1
      self.total_cost = (hours * hourly_rate * multiplier).round(2)
    end
  end
end

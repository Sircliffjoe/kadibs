# frozen_string_literal: true

class MeterReading < ApplicationRecord
  has_paper_trail

  belongs_to :asset
  belongs_to :recorded_by, class_name: "User"
  belongs_to :work_order, optional: true

  validates :meter_type, presence: true
  validates :reading, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :recorded_at, presence: true

  before_save :calculate_usage

  private

  def calculate_usage
    self.usage_since_last = previous_reading.present? ? (reading - previous_reading) : nil
  end
end

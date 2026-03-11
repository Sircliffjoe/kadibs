# frozen_string_literal: true

class StockMovement < ApplicationRecord
  has_paper_trail

  belongs_to :part
  belongs_to :stock_location, optional: true
  belongs_to :destination_location, class_name: "StockLocation", optional: true
  belongs_to :user
  belongs_to :work_order, optional: true
  belongs_to :purchase_requisition, optional: true

  MOVEMENT_TYPES = %w[
    receipt issue transfer adjustment_in adjustment_out
    reservation release return scrap cycle_count
  ].freeze

  validates :movement_type, presence: true, inclusion: { in: MOVEMENT_TYPES }
  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :movement_date, presence: true

  scope :receipts, -> { where(movement_type: "receipt") }
  scope :issues, -> { where(movement_type: "issue") }
  scope :adjustments, -> { where(movement_type: %w[adjustment_in adjustment_out]) }
  scope :for_part, ->(part_id) { where(part_id: part_id) }
  scope :between_dates, ->(start_date, end_date) { where(movement_date: start_date..end_date) }
end

# frozen_string_literal: true

class WorkOrderPart < ApplicationRecord
  has_paper_trail

  belongs_to :work_order
  belongs_to :part
  belongs_to :issued_by, class_name: "User", optional: true

  validates :quantity_requested, presence: true, numericality: { greater_than: 0 }

  before_save :calculate_total_cost

  scope :pending, -> { where(status: "requested") }
  scope :issued, -> { where(status: "issued") }
  scope :used, -> { where(status: "used") }

  private

  def calculate_total_cost
    if quantity_used.present? && unit_cost.present?
      self.total_cost = (quantity_used * unit_cost).round(2)
    elsif quantity_requested.present? && unit_cost.present?
      self.total_cost = (quantity_requested * unit_cost).round(2)
    end
  end
end

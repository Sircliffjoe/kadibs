# frozen_string_literal: true

class PurchaseRequisitionItem < ApplicationRecord
  belongs_to :purchase_requisition
  belongs_to :part

  validates :quantity_requested, presence: true, numericality: { greater_than: 0 }

  before_save :calculate_total

  private

  def calculate_total
    self.total_price = (quantity_requested || 0) * (unit_price || 0)
  end
end

# frozen_string_literal: true

class InventoryItem < ApplicationRecord
  has_paper_trail

  belongs_to :part
  belongs_to :stock_location

  scope :in_stock, -> { where("quantity > 0") }
  scope :expiring_soon, ->(days = 30) { where("expiry_date <= ?", days.days.from_now) }
  scope :expired, -> { where("expiry_date < ?", Date.current) }

  validates :quantity, numericality: { greater_than_or_equal_to: 0 }

  def available_quantity
    quantity - reserved_quantity
  end

  def expired?
    expiry_date.present? && expiry_date < Date.current
  end
end

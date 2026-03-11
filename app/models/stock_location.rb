# frozen_string_literal: true

class StockLocation < ApplicationRecord
  has_paper_trail

  belongs_to :warehouse

  has_many :inventory_items, dependent: :restrict_with_error
  has_many :stock_movements, dependent: :nullify
  has_many :goods_receipt_items, dependent: :nullify

  scope :active, -> { where(active: true) }

  validates :name, presence: true
  validates :code, presence: true, uniqueness: { scope: :warehouse_id }

  def full_location
    [ aisle, rack, shelf, bin ].compact.join("-")
  end

  def full_name
    "#{warehouse.name} - #{code}"
  end
end

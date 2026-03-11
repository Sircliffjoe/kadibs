# frozen_string_literal: true

class GoodsReceiptItem < ApplicationRecord
  belongs_to :goods_receipt
  belongs_to :part
  belongs_to :purchase_requisition_item, optional: true
  belongs_to :stock_location

  validates :quantity_received, presence: true, numericality: { greater_than_or_equal_to: 0 }
end

# frozen_string_literal: true

class GoodsReceipt < ApplicationRecord
  has_paper_trail

  belongs_to :organization
  belongs_to :purchase_requisition, optional: true
  belongs_to :supplier, optional: true
  belongs_to :warehouse
  belongs_to :received_by, class_name: "User"

  has_many :goods_receipt_items, dependent: :destroy


  validates :number, presence: true, uniqueness: { scope: :organization_id }
  validates :receipt_date, presence: true

  before_validation :generate_number, on: :create

  private

  def generate_number
    return if number.present?
    last = organization.goods_receipts.maximum(:number)&.gsub(/\D/, "")&.to_i || 0
    self.number = "GR-#{(last + 1).to_s.rjust(6, '0')}"
  end
end

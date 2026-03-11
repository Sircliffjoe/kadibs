# frozen_string_literal: true

class Warehouse < ApplicationRecord
  has_paper_trail

  belongs_to :organization
  belongs_to :location, optional: true
  belongs_to :manager, class_name: "User", optional: true

  has_many :stock_locations, dependent: :destroy
  has_many :inventory_items, through: :stock_locations
  has_many :purchase_requisitions, dependent: :nullify
  has_many :goods_receipts, dependent: :nullify


  scope :active, -> { where(active: true) }

  validates :name, presence: true
  validates :code, presence: true, uniqueness: { scope: :organization_id }

  before_validation :generate_code, on: :create, if: -> { code.blank? }

  def default!
    transaction do
      organization.warehouses.where.not(id: id).update_all(default_warehouse: false)
      update!(default_warehouse: true)
    end
  end

  private

  def generate_code
    base = name.to_s.parameterize.underscore.upcase[0, 6]
    self.code = "WH-#{base}-#{SecureRandom.hex(2).upcase}"
  end
end

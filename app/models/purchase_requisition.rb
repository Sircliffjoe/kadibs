# frozen_string_literal: true

class PurchaseRequisition < ApplicationRecord
  include AASM
  has_paper_trail

  belongs_to :organization
  belongs_to :requested_by, class_name: "User"
  belongs_to :approved_by, class_name: "User", optional: true
  belongs_to :supplier, optional: true
  belongs_to :warehouse, optional: true
  belongs_to :work_order, optional: true

  has_many :purchase_requisition_items, dependent: :destroy
  accepts_nested_attributes_for :purchase_requisition_items, allow_destroy: true, reject_if: :all_blank
  has_many :parts, through: :purchase_requisition_items
  has_many :goods_receipts, dependent: :nullify
  has_many :stock_movements, dependent: :nullify


  aasm column: :status do
    state :draft, initial: true
    state :pending_approval
    state :approved
    state :rejected
    state :ordered
    state :partially_received
    state :received
    state :cancelled
    state :closed

    event :submit do
      transitions from: :draft, to: :pending_approval, after: :set_submitted_at
    end

    event :approve do
      transitions from: :pending_approval, to: :approved, after: :set_approved_at
    end

    event :reject do
      transitions from: :pending_approval, to: :rejected, after: :set_rejected_at
    end

    event :mark_ordered do
      transitions from: :approved, to: :ordered, after: :set_ordered_at
    end

    event :partially_receive do
      transitions from: :ordered, to: :partially_received
    end

    event :receive do
      transitions from: [ :ordered, :partially_received ], to: :received, after: :set_received_at
    end

    event :cancel do
      transitions from: [ :draft, :pending_approval, :approved ], to: :cancelled
    end

    event :close do
      transitions from: :received, to: :closed
    end
  end

  validates :number, presence: true, uniqueness: { scope: :organization_id }

  before_validation :generate_number, on: :create
  before_save :calculate_totals

  private

  def generate_number
    return if number.present?
    last = organization.purchase_requisitions.maximum(:number)&.gsub(/\D/, "")&.to_i || 0
    self.number = "PR-#{(last + 1).to_s.rjust(6, '0')}"
  end

  def calculate_totals
    self.subtotal = purchase_requisition_items.sum(&:total_price)
    self.total_amount = subtotal.to_f + tax_amount.to_f + shipping_cost.to_f
  end

  def set_submitted_at
    update_column(:submitted_at, Time.current)
  end

  def set_approved_at
    update_column(:approved_at, Time.current)
  end

  def set_rejected_at
    update_column(:rejected_at, Time.current)
  end

  def set_ordered_at
    update_column(:ordered_at, Time.current)
  end

  def set_received_at
    update_column(:received_at, Time.current)
  end
end

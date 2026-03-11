# frozen_string_literal: true

class WorkOrderChecklist < ApplicationRecord
  belongs_to :work_order

  has_many :work_order_checklist_items, dependent: :destroy

  validates :title, presence: true

  def completed?
    work_order_checklist_items.all?(&:completed?)
  end

  def completion_percentage
    items = work_order_checklist_items
    return 100 if items.empty?
    (items.where(completed: true).count.to_f / items.count * 100).round
  end
end

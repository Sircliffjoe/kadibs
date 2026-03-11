# frozen_string_literal: true

class WorkOrderChecklistItem < ApplicationRecord
  belongs_to :work_order_checklist
  belongs_to :completed_by, class_name: "User", optional: true

  validates :description, presence: true

  def complete!(user, value = nil)
    update!(
      completed: true,
      completed_at: Time.current,
      completed_by: user,
      actual_value: value
    )
  end
end

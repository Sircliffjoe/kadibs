# frozen_string_literal: true

class WorkOrderComment < ApplicationRecord
  belongs_to :work_order
  belongs_to :user

  validates :content, presence: true

  scope :public_only, -> { where(internal: false) }
  scope :internal_only, -> { where(internal: true) }
  scope :status_changes, -> { where(comment_type: "status_change") }
end

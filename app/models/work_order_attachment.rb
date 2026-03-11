# frozen_string_literal: true

class WorkOrderAttachment < ApplicationRecord
  belongs_to :work_order
  belongs_to :uploaded_by, class_name: "User"

  has_one_attached :file
end

# frozen_string_literal: true

class AssetTransfer < ApplicationRecord
  has_paper_trail

  belongs_to :asset
  belongs_to :from_location, class_name: "Location", optional: true
  belongs_to :to_location, class_name: "Location"
  belongs_to :transferred_by, class_name: "User"
  belongs_to :approved_by, class_name: "User", optional: true

  validates :transferred_at, presence: true
  validates :status, presence: true

  scope :pending, -> { where(status: "pending") }
  scope :completed, -> { where(status: "completed") }
end

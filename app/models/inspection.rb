# frozen_string_literal: true

class Inspection < ApplicationRecord
  include Discard::Model
  include AASM

  belongs_to :organization
  belongs_to :asset, optional: true
  belongs_to :work_order, optional: true
  belongs_to :inspector, class_name: "User", optional: true

  has_many :inspection_items, dependent: :destroy
  accepts_nested_attributes_for :inspection_items, allow_destroy: true, reject_if: :all_blank

  validates :title, presence: true
  validates :status, presence: true

  scope :pending, -> { where(status: "pending") }
  scope :in_progress, -> { where(status: "in_progress") }
  scope :completed, -> { where(status: "completed") }
  scope :failed, -> { where(status: "failed") }

  aasm column: :status do
    state :pending, initial: true
    state :in_progress
    state :completed
    state :failed

    event :start do
      transitions from: :pending, to: :in_progress
    end

    event :complete do
      transitions from: :in_progress, to: :completed, after: :set_completed_at
    end

    event :fail do
      transitions from: [ :in_progress, :completed ], to: :failed, after: :set_completed_at
    end
  end

  def set_completed_at
    update(completed_at: Time.current)
  end
end

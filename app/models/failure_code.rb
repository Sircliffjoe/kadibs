# frozen_string_literal: true

class FailureCode < ApplicationRecord
  has_paper_trail

  belongs_to :organization
  belongs_to :parent, class_name: "FailureCode", optional: true

  has_many :children, class_name: "FailureCode", foreign_key: :parent_id, dependent: :nullify


  scope :active, -> { where(active: true) }
  scope :problems, -> { where(code_type: "problem") }
  scope :causes, -> { where(code_type: "cause") }
  scope :remedies, -> { where(code_type: "remedy") }

  TYPES = %w[problem cause remedy].freeze

  validates :code, presence: true, uniqueness: { scope: :organization_id }
  validates :name, presence: true
  validates :code_type, presence: true, inclusion: { in: TYPES }

  def full_code
    parent.present? ? "#{parent.code} > #{code}" : code
  end
end

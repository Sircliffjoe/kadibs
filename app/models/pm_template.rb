# frozen_string_literal: true

class PmTemplate < ApplicationRecord
  has_paper_trail

  belongs_to :organization
  belongs_to :asset_category, optional: true

  has_many :preventive_maintenance_schedules, dependent: :nullify


  scope :active, -> { where(active: true) }

  validates :name, presence: true
  validates :code, uniqueness: { scope: :organization_id, allow_blank: true }
end

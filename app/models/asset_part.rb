# frozen_string_literal: true

class AssetPart < ApplicationRecord
  belongs_to :asset
  belongs_to :part

  validates :asset_id, uniqueness: { scope: :part_id }
  validates :quantity_required, numericality: { greater_than: 0 }
end

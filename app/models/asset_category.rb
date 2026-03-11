# frozen_string_literal: true

class AssetCategory < ApplicationRecord
  include Discard::Model

  has_paper_trail

  # ===========================================================================
  # Associations
  # ===========================================================================
  belongs_to :organization
  belongs_to :parent, class_name: "AssetCategory", optional: true

  has_many :children, class_name: "AssetCategory", foreign_key: :parent_id, dependent: :nullify
  has_many :assets, dependent: :nullify

  # ===========================================================================
  # Scopes
  # ===========================================================================
  default_scope -> { kept }

  scope :root_categories, -> { where(parent_id: nil) }

  # ===========================================================================
  # Validations
  # ===========================================================================
  validates :name, presence: true
  validates :code, presence: true,
                   uniqueness: { scope: :organization_id, case_sensitive: false }

  # ===========================================================================
  # Callbacks
  # ===========================================================================
  before_validation :upcase_code

  # ===========================================================================
  # Instance Methods
  # ===========================================================================
  def full_path
    ancestors.reverse.push(self).map(&:name).join(" > ")
  end

  def ancestors
    result = []
    current = parent
    while current
      result << current
      current = current.parent
    end
    result
  end

  def descendants
    result = []
    children.each do |child|
      result << child
      result.concat(child.descendants)
    end
    result
  end

  def asset_count
    assets.count + descendants.sum { |d| d.assets.count }
  end

  private

  def upcase_code
    self.code = code&.upcase
  end
end

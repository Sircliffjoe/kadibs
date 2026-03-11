# frozen_string_literal: true

# Location represents physical areas like plants, sites, buildings, zones.
# Supports hierarchical structure where locations can have parent/child relationships.
class Location < ApplicationRecord
  include Discard::Model

  has_paper_trail

  # ==========================================================================
  # Constants
  # ==========================================================================
  LOCATION_TYPES = %w[plant site building zone area room floor].freeze

  store_accessor :address, :street, :city, :state, :postal_code, :country

  # ==========================================================================
  # Multi-tenancy
  # ==========================================================================

  # ==========================================================================
  # Associations
  # ==========================================================================
  belongs_to :organization
  belongs_to :parent, class_name: "Location", optional: true

  has_many :children, class_name: "Location", foreign_key: :parent_id, dependent: :destroy
  has_many :assets, dependent: :nullify
  has_many :work_orders, dependent: :nullify
  has_many :warehouses, dependent: :destroy

  # ==========================================================================
  # Validations
  # ==========================================================================
  validates :name, presence: true, length: { maximum: 255 }
  validates :code, presence: true,
                   length: { maximum: 50 },
                   uniqueness: { scope: :organization_id }
  validates :location_type, inclusion: { in: LOCATION_TYPES }, allow_blank: true
  validates :latitude, numericality: { greater_than_or_equal_to: -90, less_than_or_equal_to: 90 }, allow_nil: true
  validates :longitude, numericality: { greater_than_or_equal_to: -180, less_than_or_equal_to: 180 }, allow_nil: true
  validate :parent_not_self
  validate :parent_not_descendant

  # ==========================================================================
  # Callbacks
  # ==========================================================================
  before_validation :generate_code, on: :create, if: -> { code.blank? }

  # ==========================================================================
  # Scopes
  # ==========================================================================
  scope :active, -> { where(active: true) }
  scope :root_locations, -> { where(parent_id: nil) }
  scope :by_type, ->(type) { where(location_type: type) }
  scope :with_coordinates, -> { where.not(latitude: nil, longitude: nil) }

  # ==========================================================================
  # Instance Methods
  # ==========================================================================

  # Get full hierarchy path (e.g., "Site A > Building 1 > Zone 2")
  def full_path
    ancestors_and_self.map(&:name).join(" > ")
  end

  # Get all ancestors (from parent to root)
  def ancestors
    result = []
    current = parent
    while current
      result.unshift(current)
      current = current.parent
    end
    result
  end

  # Ancestors including self
  def ancestors_and_self
    ancestors + [ self ]
  end

  # Get all descendants (recursive)
  def descendants
    result = []
    children.each do |child|
      result << child
      result.concat(child.descendants)
    end
    result
  end

  # Check if location has any assets
  def has_assets?
    assets.exists?
  end

  # Count all assets including descendants
  def total_assets_count
    assets.count + descendants.sum { |d| d.assets.count }
  end

  # Get depth in hierarchy (0 = root)
  def depth
    ancestors.size
  end

  # Check if this is a root location
  def root?
    parent_id.nil?
  end

  # Check if this is a leaf (no children)
  def leaf?
    children.empty?
  end

  # Full address as string
  def full_address
    [
      address["street"],
      address["city"],
      address["state"],
      address["postal_code"],
      address["country"]
    ].compact.join(", ")
  end

  # Get coordinates as hash
  def coordinates
    return nil unless latitude && longitude
    { lat: latitude.to_f, lng: longitude.to_f }
  end

  private

  def generate_code
    base = name.to_s.parameterize.underscore.upcase[0, 10]
    self.code = "#{base}-#{SecureRandom.hex(3).upcase}"
  end

  def parent_not_self
    if parent_id == id && id.present?
      errors.add(:parent, "cannot be the location itself")
    end
  end

  def parent_not_descendant
    return unless parent_id_changed? && parent_id.present?

    if descendants.map(&:id).include?(parent_id)
      errors.add(:parent, "cannot be a descendant of this location")
    end
  end
end

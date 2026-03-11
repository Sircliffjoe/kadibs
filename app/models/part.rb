# frozen_string_literal: true

class Part < ApplicationRecord
  include Discard::Model
  include PgSearch::Model

  has_paper_trail

  # ===========================================================================
  # Associations
  # ===========================================================================
  belongs_to :organization
  belongs_to :part_category, optional: true
  belongs_to :preferred_supplier, class_name: "Supplier", optional: true
  belongs_to :default_stock_location, class_name: "StockLocation", optional: true

  has_many :inventory_items, dependent: :destroy
  has_many :asset_parts, dependent: :destroy
  has_many :assets, through: :asset_parts
  has_many :work_order_parts, dependent: :restrict_with_error
  has_many :stock_movements, dependent: :destroy
  has_many :purchase_requisition_items, dependent: :restrict_with_error
  has_many :goods_receipt_items, dependent: :restrict_with_error

  has_one_attached :image

  # ===========================================================================
  # Tenant Scoping
  # ===========================================================================
  default_scope -> { kept }

  # ===========================================================================
  # Full-Text Search
  # ===========================================================================
  pg_search_scope :search_all,
                  against: [ :name, :part_number, :manufacturer, :barcode ],
                  using: { tsearch: { prefix: true, dictionary: "english" } }

  # ===========================================================================
  # Scopes
  # ===========================================================================
  scope :low_stock, -> { where("quantity_on_hand <= reorder_level") }
  scope :out_of_stock, -> { where("quantity_on_hand <= 0") }
  scope :in_stock, -> { where("quantity_on_hand > 0") }
  scope :critical_stock, -> { where("quantity_on_hand <= minimum_stock") }
  scope :expiring_soon, ->(days = 30) {
    joins(:inventory_items)
      .where("inventory_items.expiry_date <= ?", days.days.from_now)
      .distinct
  }

  scope :by_type, ->(type) { where(part_type: type) }
  scope :spare_parts, -> { by_type("spare") }
  scope :consumables, -> { by_type("consumable") }
  scope :tools, -> { by_type("tool") }

  # ===========================================================================
  # Validations
  # ===========================================================================
  PART_TYPES = %w[spare consumable tool raw_material safety_equipment lubricant].freeze
  COSTING_METHODS = %w[average fifo lifo standard].freeze

  validates :name, presence: true
  validates :part_number, presence: true,
                          uniqueness: { scope: :organization_id, case_sensitive: false }
  validates :part_type, inclusion: { in: PART_TYPES }, allow_blank: true
  validates :costing_method, inclusion: { in: COSTING_METHODS }
  validates :minimum_stock, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :reorder_level, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  # ===========================================================================
  # Callbacks
  # ===========================================================================
  before_save :calculate_available_quantity
  after_save :check_reorder_alert, if: :saved_change_to_quantity_on_hand?

  # ===========================================================================
  # Instance Methods
  # ===========================================================================
  def low_stock?
    reorder_level.present? && quantity_on_hand <= reorder_level
  end

  def out_of_stock?
    quantity_on_hand <= 0
  end

  def critical_stock?
    minimum_stock.present? && quantity_on_hand <= minimum_stock
  end

  def available_quantity
    quantity_on_hand - quantity_reserved
  end

  def stock_value
    quantity_on_hand * (average_cost || unit_cost || 0)
  end

  def adjust_stock!(quantity:, movement_type:, user:, stock_location: nil, reason: nil)
    transaction do
      old_balance = quantity_on_hand

      case movement_type
      when "adjustment_in", "receipt", "return"
        self.quantity_on_hand += quantity
      when "adjustment_out", "issue", "scrap"
        raise "Insufficient stock" if quantity > quantity_on_hand
        self.quantity_on_hand -= quantity
      end

      save!

      stock_movements.create!(
        stock_location: stock_location || default_stock_location,
        user: user,
        movement_type: movement_type,
        quantity: quantity,
        balance_before: old_balance,
        balance_after: quantity_on_hand,
        reason: reason,
        movement_date: Time.current
      )
    end
  end

  def reserve!(quantity, user:)
    raise "Insufficient available stock" if quantity > available_quantity

    transaction do
      old_balance = quantity_reserved
      self.quantity_reserved += quantity
      save!

      stock_movements.create!(
        user: user,
        movement_type: "reservation",
        quantity: quantity,
        balance_before: old_balance,
        balance_after: quantity_reserved,
        movement_date: Time.current
      )
    end
  end

  def release_reservation!(quantity, user:)
    transaction do
      old_balance = quantity_reserved
      self.quantity_reserved = [ quantity_reserved - quantity, 0 ].max
      save!

      stock_movements.create!(
        user: user,
        movement_type: "release",
        quantity: quantity,
        balance_before: old_balance,
        balance_after: quantity_reserved,
        movement_date: Time.current
      )
    end
  end

  def update_average_cost!(new_quantity, new_unit_cost)
    return unless costing_method == "average"

    total_value = (quantity_on_hand * (average_cost || 0)) + (new_quantity * new_unit_cost)
    new_total_quantity = quantity_on_hand + new_quantity

    self.average_cost = new_total_quantity.positive? ? (total_value / new_total_quantity) : new_unit_cost
    save!
  end

  private

  def calculate_available_quantity
    self.quantity_available = quantity_on_hand - quantity_reserved
  end

  def check_reorder_alert
    nil unless low_stock?
    # TODO: Trigger low stock notification/alert
  end
end

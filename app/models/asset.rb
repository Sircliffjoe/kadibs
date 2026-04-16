# frozen_string_literal: true

class Asset < ApplicationRecord
  include Discard::Model
  include PgSearch::Model

  has_paper_trail

  # ===========================================================================
  # Associations
  # ===========================================================================
  belongs_to :organization
  belongs_to :location, optional: true
  belongs_to :asset_category, optional: true
  belongs_to :parent, class_name: "Asset", optional: true

  has_many :children, class_name: "Asset", foreign_key: :parent_id, dependent: :nullify
  has_many :work_orders, dependent: :restrict_with_error
  has_many :meter_readings, dependent: :destroy
  has_many :asset_transfers, dependent: :destroy
  has_many :asset_parts, dependent: :destroy
  has_many :parts, through: :asset_parts
  has_many :preventive_maintenance_schedules, dependent: :destroy

  has_many_attached :photos
  has_many_attached :documents

  # ===========================================================================
  # Tenant Scoping
  # ===========================================================================
  default_scope -> { kept }

  # ===========================================================================
  # Full-Text Search
  # ===========================================================================
  pg_search_scope :search_all,
                  against: [ :name, :code, :serial_number, :barcode, :manufacturer, :model ],
                  using: {
                    tsearch: { prefix: true, dictionary: "english" }
                  }

  # ===========================================================================
  # Scopes
  # ===========================================================================
  scope :operational, -> { where(status: "operational") }
  scope :under_maintenance, -> { where(status: "under_maintenance") }
  scope :out_of_service, -> { where(status: "out_of_service") }
  scope :decommissioned, -> { where(status: "decommissioned") }

  scope :by_criticality, ->(level) { where(criticality: level) }
  scope :critical, -> { where(criticality: "critical") }

  scope :warranty_expiring_soon, ->(days = 30) {
    where("warranty_end_date > ? AND warranty_end_date <= ?", Date.current, days.days.from_now)
  }

  scope :maintenance_due, -> { where("next_maintenance_date <= ?", Date.current) }

  # ===========================================================================
  # Validations
  # ===========================================================================
  ASSET_TYPES = %w[equipment vehicle facility tool infrastructure component].freeze
  CRITICALITIES = %w[critical high medium low].freeze
  STATUSES = %w[operational under_maintenance out_of_service decommissioned].freeze

  validates :name, presence: true
  validates :code, presence: true,
                   uniqueness: { scope: :organization_id, case_sensitive: false }
  validates :asset_type, inclusion: { in: ASSET_TYPES }, allow_blank: true
  validates :criticality, inclusion: { in: CRITICALITIES }, allow_blank: true
  validates :status, inclusion: { in: STATUSES }
  validates :serial_number, uniqueness: { scope: :organization_id, allow_blank: true }

  # ===========================================================================
  # Callbacks
  # ===========================================================================
  before_validation :generate_code, if: -> { code.blank? }
  before_validation :upcase_code
  before_validation :generate_qr_code_data, if: -> { qr_code_data.blank? }
  after_create :calculate_current_value

  # ===========================================================================
  # Instance Methods
  # ===========================================================================
  def full_location
    parts = []
    parts << building if building.present?
    parts << floor if floor.present?
    parts << room if room.present?
    parts << location&.name if location.present?
    parts.join(" / ")
  end

  def operational?
    status == "operational"
  end

  def under_maintenance?
    status == "under_maintenance"
  end

  def warranty_active?
    warranty_end_date.present? && warranty_end_date >= Date.current
  end

  def warranty_days_remaining
    return nil unless warranty_end_date.present?
    (warranty_end_date - Date.current).to_i
  end

  def age_in_years
    return nil unless purchase_date.present?
    ((Date.current - purchase_date) / 365.25).round(1)
  end

  def uptime_percentage
    return 100 if total_operating_hours.to_f.zero? && total_downtime_hours.to_f.zero?
    total = total_operating_hours.to_f + total_downtime_hours.to_f
    return 100 if total.zero?
    ((total_operating_hours.to_f / total) * 100).round(2)
  end

  def mtbf
    # Mean Time Between Failures
    return nil if failure_count.to_i.zero?
    (total_operating_hours.to_f / failure_count).round(2)
  end

  def record_meter_reading!(reading, meter_type: nil, user:, work_order: nil)
    meter_type ||= self.meter_unit || "hours"

    MeterReading.create!(
      asset: self,
      meter_type: meter_type,
      reading: reading,
      previous_reading: meter_reading,
      usage_since_last: meter_reading.present? ? (reading - meter_reading) : nil,
      recorded_at: Time.current,
      recorded_by: user,
      work_order: work_order
    )

    update!(
      meter_reading: reading,
      meter_reading_at: Time.current,
      meter_unit: meter_type
    )
  end

  def transfer_to!(location, transferred_by:, reason: nil)
    old_location = self.location

    AssetTransfer.create!(
      asset: self,
      from_location: old_location,
      to_location: location,
      transferred_by: transferred_by,
      transferred_at: Time.current,
      status: "completed",
      reason: reason
    )

    update!(location: location)
  end

  def qr_code_svg
    return nil if qr_code_data.blank?
    RQRCode::QRCode.new(qr_code_data).as_svg(
      color: "000",
      shape_rendering: "crispEdges",
      module_size: 4,
      standalone: true
    )
  end

  def critical_parts
    asset_parts.where(critical: true).includes(:part)
  end

  private

  def generate_code
    prefix = "AST"
    loop do
      new_code = "#{prefix}-#{SecureRandom.hex(4).upcase}"
      unless self.class.unscoped.exists?(code: new_code, organization_id: organization_id)
        self.code = new_code
        break
      end
    end
  end

  def upcase_code
    self.code = code&.upcase
  end

  def generate_qr_code_data
    self.qr_code_data = "ASSET:#{organization_id}:#{code}"
  end

  def calculate_current_value
    return unless purchase_price.present? && depreciation_method.present?
    # Initial current value equals purchase price
    update_column(:current_value, purchase_price)
  end
end

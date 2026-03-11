# frozen_string_literal: true

# Organization is the root tenant in a multi-tenant CMMS system.
# All resources are scoped to an organization for data isolation.
class Organization < ApplicationRecord
  extend FriendlyId
  include Discard::Model

  has_paper_trail

  friendly_id :name, use: :slugged

  # ==========================================================================
  # Associations
  # ==========================================================================
  has_many :users, dependent: :destroy
  has_many :roles, dependent: :destroy
  has_many :locations, dependent: :destroy

  # Module 2: Asset Management
  has_many :asset_categories, dependent: :destroy
  has_many :assets, dependent: :destroy

  # Module 3 & 4: Work Orders & PM
  has_many :failure_codes, dependent: :destroy
  has_many :work_orders, dependent: :destroy
  has_many :pm_templates, dependent: :destroy
  has_many :preventive_maintenance_schedules, dependent: :destroy

  # Module 5: Inventory
  has_many :suppliers, dependent: :destroy
  has_many :warehouses, dependent: :destroy
  has_many :parts, dependent: :destroy

  # Module 6: Workforce
  has_many :skills, dependent: :destroy
  has_many :certifications, dependent: :destroy
  has_many :shifts, dependent: :destroy

  # Module 7: Financial
  has_many :cost_centers, dependent: :destroy
  has_many :budgets, dependent: :destroy

  # Module 8: Compliance
  has_many :safety_procedures, dependent: :destroy
  has_many :permits_to_work, dependent: :destroy
  has_many :compliance_checklists, dependent: :destroy

  # Module 10: Notifications
  has_many :notifications, dependent: :destroy
  has_many :alert_configurations, dependent: :destroy

  # Module 12: API & Integrations
  has_many :api_keys, dependent: :destroy
  has_many :webhooks, dependent: :destroy
  has_many :data_imports, dependent: :destroy

  # ==========================================================================
  # Validations
  # ==========================================================================
  validates :name, presence: true, length: { maximum: 255 }
  validates :slug, presence: true, uniqueness: true
  validates :timezone, presence: true
  validates :currency, presence: true, length: { is: 3 }
  validates :status, inclusion: { in: %w[active suspended cancelled] }
  validates :plan, inclusion: { in: %w[starter professional enterprise] }

  # ==========================================================================
  # Callbacks
  # ==========================================================================
  after_create :create_default_roles

  # ==========================================================================
  # Scopes
  # ==========================================================================
  scope :active, -> { where(status: "active") }

  # ==========================================================================
  # Instance Methods
  # ==========================================================================

  # Get a setting value with optional default
  def setting(key, default = nil)
    settings.dig(key.to_s) || default
  end

  # Set a setting value
  def set_setting(key, value)
    self.settings = settings.merge(key.to_s => value)
    save
  end



  # Full address as a string
  def full_address
    [
      address,
      city,
      state,
      zip_code,
      country
    ].compact.join(", ")
  end

  private

  def create_default_roles
    default_roles.each do |role_data|
      roles.create!(
        name: role_data[:name],
        slug: role_data[:slug],
        description: role_data[:description],
        permissions: role_data[:permissions],
        system_role: true
      )
    end
  end

  def default_roles
    [
      {
        name: "Organization Admin",
        slug: "org_admin",
        description: "Full access to organization settings and resources",
        permissions: { "*" => [ "*" ] }
      },
      {
        name: "Maintenance Manager",
        slug: "maintenance_manager",
        description: "Manage assets, work orders, inventory, and technicians",
        permissions: {
          "assets" => %w[read create update delete],
          "work_orders" => %w[read create update delete assign verify close],
          "inventory" => %w[read create update],
          "pm_schedules" => %w[read create update delete],
          "technicians" => %w[read update assign],
          "reports" => %w[read export]
        }
      },
      {
        name: "Technician",
        slug: "technician",
        description: "Execute work orders and log maintenance activities",
        permissions: {
          "assets" => %w[read],
          "work_orders" => %w[read update complete],
          "inventory" => %w[read issue],
          "pm_schedules" => %w[read]
        }
      },
      {
        name: "Storekeeper",
        slug: "storekeeper",
        description: "Manage inventory and spare parts",
        permissions: {
          "assets" => %w[read],
          "inventory" => %w[read create update receive issue adjust],
          "suppliers" => %w[read create update],
          "purchase_requisitions" => %w[read create update]
        }
      },
      {
        name: "Auditor",
        slug: "auditor",
        description: "View-only access for compliance and audit purposes",
        permissions: {
          "assets" => %w[read],
          "work_orders" => %w[read],
          "inventory" => %w[read],
          "pm_schedules" => %w[read],
          "compliance" => %w[read],
          "audit_logs" => %w[read],
          "reports" => %w[read export]
        }
      }
    ]
  end
end

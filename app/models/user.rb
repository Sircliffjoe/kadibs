# frozen_string_literal: true

# User model with Devise authentication and multi-tenancy support.
# Users belong to an organization and can have multiple roles.
class User < ApplicationRecord
  include Discard::Model

  # Virtual attribute for organization creation during registration
  attr_accessor :organization_name

  has_paper_trail ignore: [ :encrypted_password, :reset_password_token, :unlock_token ]

  # ==========================================================================
  # Devise Configuration
  # ==========================================================================
  devise :database_authenticatable,
         :recoverable, :rememberable, :validatable,
         :lockable, :trackable

  # ==========================================================================
  # Multi-tenancy
  # ==========================================================================

  # ==========================================================================
  # Associations
  # ==========================================================================
  belongs_to :organization

  # Roles
  has_many :user_roles, dependent: :destroy
  has_many :roles, through: :user_roles

  # Workforce (optional technician profile)
  has_one :technician_profile, dependent: :destroy

  # Work Order relationships
  has_many :requested_work_orders, class_name: "WorkOrder", foreign_key: :requester_id
  has_many :assigned_work_orders, class_name: "WorkOrder", foreign_key: :assigned_to_id
  has_many :supervised_work_orders, class_name: "WorkOrder", foreign_key: :supervisor_id
  has_many :work_order_labors
  has_many :work_order_comments

  # Inventory
  has_many :stock_movements, dependent: :restrict_with_error
  has_many :purchase_requisitions, foreign_key: :requested_by_id

  # Skills & Certifications
  has_many :user_skills, dependent: :destroy
  has_many :skills, through: :user_skills
  has_many :user_certifications, dependent: :destroy
  has_many :certifications, through: :user_certifications

  # Shifts
  has_many :user_shifts, dependent: :destroy
  has_many :shifts, through: :user_shifts

  # Notifications
  has_many :notifications, foreign_key: :recipient_id, dependent: :destroy
  has_many :notification_preferences, dependent: :destroy

  # Asset transfers
  has_many :asset_transfers, foreign_key: :transferred_by_id

  # Meter readings
  has_many :meter_readings, foreign_key: :recorded_by_id

  # Sign-offs
  has_many :sign_offs, dependent: :destroy

  # ==========================================================================
  # Validations
  # ==========================================================================
  validates :first_name, presence: true, length: { maximum: 100 }
  validates :last_name, presence: true, length: { maximum: 100 }
  validates :email, presence: true
  validates :employee_id, uniqueness: { scope: :organization_id }, allow_blank: true
  validates :phone, phone: { allow_blank: true, possible: true }

  # ==========================================================================
  # Scopes
  # ==========================================================================
  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }
  scope :super_admins, -> { where(super_admin: true) }
  scope :technicians, -> { joins(:technician_profile) }
  scope :with_role, ->(slug) { joins(:roles).where(roles: { slug: slug }) }

  # ==========================================================================
  # Instance Methods
  # ==========================================================================

  def full_name
    "#{first_name} #{last_name}".strip
  end

  def full_name_email
    "#{full_name} (#{email})"
  end

  def initials
    "#{first_name[0]}#{last_name[0]}".upcase
  end

  # Check if user has a specific role
  def has_role?(role_slug)
    roles.exists?(slug: role_slug)
  end

  # Check if user has any of the given roles
  def has_any_role?(*role_slugs)
    roles.where(slug: role_slugs).exists?
  end

  # Check if user can perform an action on a resource
  def can?(action, resource)
    return true if super_admin?
    return true if has_role?("org_admin")

    roles.any? do |role|
      perms = role.permissions[resource.to_s]
      perms.present? && (perms.include?(action.to_s) || perms.include?("*"))
    end
  end

  # Check if the user is a technician
  def technician?
    technician_profile.present? || has_role?("technician")
  end

  def admin?
    has_role?("admin") || super_admin?
  end

  def manager?
    has_role?("manager") || has_role?("org_admin")
  end

  # Get the user's current shift (if any)
  def current_shift
    user_shifts.joins(:shift)
               .where("start_date <= ? AND (end_date IS NULL OR end_date >= ?)",
                      Date.current, Date.current)
               .first&.shift
  end

  # Check if user has valid certification for a given certification type
  def certified_for?(certification)
    user_certifications.active
                       .where(certification: certification)
                       .where("expiry_date IS NULL OR expiry_date > ?", Date.current)
                       .exists?
  end

  # Get user preference with default
  def preference(key, default = nil)
    preferences.dig(key.to_s) || default
  end

  # Set user preference
  def set_preference(key, value)
    self.preferences = preferences.merge(key.to_s => value)
    save
  end

  # Override Devise to check if account is active
  def active_for_authentication?
    super && active? && kept?
  end

  # Message for inactive account
  def inactive_message
    if !active?
      :account_deactivated
    elsif discarded?
      :account_deleted
    else
      super
    end
  end
end

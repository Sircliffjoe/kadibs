# frozen_string_literal: true

# Role defines a set of permissions that can be assigned to users.
# Permissions are stored as JSON for flexibility.
class Role < ApplicationRecord
  has_paper_trail

  # ==========================================================================
  # Multi-tenancy
  # ==========================================================================

  # ==========================================================================
  # Associations
  # ==========================================================================
  belongs_to :organization
  has_many :user_roles, dependent: :destroy
  has_many :users, through: :user_roles

  # ==========================================================================
  # Validations
  # ==========================================================================
  validates :name, presence: true, length: { maximum: 100 }
  validates :slug, presence: true,
                   format: { with: /\A[a-z][a-z0-9_]*\z/, message: "must be lowercase letters, numbers, and underscores" },
                   uniqueness: { scope: :organization_id }

  # ==========================================================================
  # Callbacks
  # ==========================================================================
  before_validation :generate_slug, on: :create
  before_destroy :prevent_system_role_deletion
  before_update :prevent_system_role_modification, if: :system_role?

  # ==========================================================================
  # Scopes
  # ==========================================================================
  scope :system_roles, -> { where(system_role: true) }
  scope :custom_roles, -> { where(system_role: false) }
  scope :assignable, -> { all }

  # ==========================================================================
  # Instance Methods
  # ==========================================================================

  # Check if role has a specific permission
  def has_permission?(resource, action)
    return true if permissions["*"]&.include?("*")

    resource_perms = permissions[resource.to_s]
    return false unless resource_perms

    resource_perms.include?(action.to_s) || resource_perms.include?("*")
  end

  # Add a permission to the role
  def add_permission(resource, action)
    self.permissions = permissions.merge(
      resource.to_s => (permissions[resource.to_s] || []).push(action.to_s).uniq
    )
  end

  # Remove a permission from the role
  def remove_permission(resource, action)
    return unless permissions[resource.to_s]

    self.permissions = permissions.merge(
      resource.to_s => permissions[resource.to_s] - [ action.to_s ]
    )
  end

  # Get all resources this role has access to
  def accessible_resources
    permissions.keys
  end

  private

  def generate_slug
    return if slug.present?
    self.slug = name.to_s.parameterize.underscore
  end

  def prevent_system_role_deletion
    if system_role?
      errors.add(:base, "System roles cannot be deleted")
      throw :abort
    end
  end

  def prevent_system_role_modification
    if permissions_changed? || name_changed? || slug_changed?
      errors.add(:base, "System role permissions cannot be modified")
      throw :abort
    end
  end
end

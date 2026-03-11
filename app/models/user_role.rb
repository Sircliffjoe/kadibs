# frozen_string_literal: true

# Join table between User and Role with tracking of who assigned the role.
class UserRole < ApplicationRecord
  has_paper_trail

  # ==========================================================================
  # Associations
  # ==========================================================================
  belongs_to :user
  belongs_to :role
  belongs_to :assigned_by, class_name: "User", optional: true

  # ==========================================================================
  # Validations
  # ==========================================================================
  validates :user_id, uniqueness: { scope: :role_id, message: "already has this role" }
  validate :role_belongs_to_same_organization

  # ==========================================================================
  # Callbacks
  # ==========================================================================
  after_create :log_role_assignment
  after_destroy :log_role_removal

  private

  def role_belongs_to_same_organization
    return unless user && role

    if user.organization_id != role.organization_id
      errors.add(:role, "must belong to the same organization as the user")
    end
  end

  def log_role_assignment
    Rails.logger.info "[AUDIT] User #{user_id} assigned role #{role.name} by #{assigned_by_id || 'system'}"
  end

  def log_role_removal
    Rails.logger.info "[AUDIT] User #{user_id} removed from role #{role.name}"
  end
end

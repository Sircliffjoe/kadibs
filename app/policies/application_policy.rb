# frozen_string_literal: true

# Base policy class for Pundit authorization.
# All policies inherit from this and follow CMMS domain rules.
class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  # Default: deny all actions
  def index?
    false
  end

  def show?
    false
  end

  def create?
    false
  end

  def new?
    create?
  end

  def update?
    false
  end

  def edit?
    update?
  end

  def destroy?
    false
  end

  # ==========================================================================
  # Helper Methods
  # ==========================================================================

  private

  # Check if user is a super admin
  def super_admin?
    user&.super_admin?
  end

  # Check if user is an organization admin
  def org_admin?
    user&.has_role?("org_admin")
  end

  # Check if user has any admin privileges
  def admin?
    super_admin? || org_admin?
  end

  # Check if user is a maintenance manager
  def maintenance_manager?
    user&.has_role?("maintenance_manager")
  end

  # Check if user is a technician
  def technician?
    user&.has_role?("technician") || user&.technician?
  end

  # Check if user is a storekeeper
  def storekeeper?
    user&.has_role?("storekeeper")
  end

  # Check if user is an auditor
  def auditor?
    user&.has_role?("auditor")
  end

  # Check permission using user's roles
  def can_perform?(action, resource)
    user&.can?(action, resource)
  end

  # Check if record belongs to user's organization
  def same_organization?
    return true if super_admin?
    return false unless user&.organization_id && record.respond_to?(:organization_id)

    user.organization_id == record.organization_id
  end

  # ==========================================================================
  # Scope Class
  # ==========================================================================

  class Scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      raise NotImplementedError, "You must define #resolve in #{self.class}"
    end

    private

    attr_reader :user, :scope

    def super_admin?
      user&.super_admin?
    end

    def org_admin?
      user&.has_role?("org_admin")
    end

    def admin?
      super_admin? || org_admin?
    end
  end
end

# frozen_string_literal: true

class WorkOrderPolicy < ApplicationPolicy
  # Role slugs used in the organization
  # org_admin, maintenance_manager, technician, storekeeper, finance

  def index?
    true
  end

  def show?
    true
  end

  def create?
    super_admin? || user.has_any_role?(:org_admin, :maintenance_manager, :technician)
  end

  def new?
    create?
  end

  def update?
    super_admin? || user.has_any_role?(:org_admin, :maintenance_manager) || record.assigned_to == user || record.requester == user
  end

  def edit?
    update?
  end

  def destroy?
    super_admin? || user.has_role?(:org_admin) || record.requester == user
  end

  def assign?
    super_admin? || user.has_any_role?(:org_admin, :maintenance_manager)
  end

  def start?
    return false unless record.respond_to?(:may_start?) && record.may_start?
    super_admin? || user.has_any_role?(:org_admin, :maintenance_manager, :technician)
  end

  def pause?
    return false unless record.respond_to?(:may_pause?) && record.may_pause?
    super_admin? || user.has_any_role?(:org_admin, :maintenance_manager) || record.assigned_to == user
  end

  def resume?
    return false unless record.respond_to?(:may_resume?) && record.may_resume?
    super_admin? || user.has_any_role?(:org_admin, :maintenance_manager) || record.assigned_to == user
  end

  def complete?
    return false unless record.respond_to?(:may_complete?) && record.may_complete?
    super_admin? || user.has_any_role?(:org_admin, :maintenance_manager) || record.assigned_to == user
  end

  def verify?
    return false unless record.respond_to?(:may_verify?) && record.may_verify?
    super_admin? || user.has_any_role?(:org_admin, :maintenance_manager)
  end

  def close?
    return false unless record.respond_to?(:may_close?) && record.may_close?
    super_admin? || user.has_any_role?(:org_admin, :maintenance_manager)
  end

  def reopen?
    super_admin? || user.has_any_role?(:org_admin, :maintenance_manager)
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if super_admin? || user.has_role?(:org_admin) || user.has_role?(:maintenance_manager)
        scope.all
      elsif user.has_role?(:technician)
        scope.where(assigned_to: user).or(scope.where(requester: user))
      else
        scope.none
      end
    end
  end
end

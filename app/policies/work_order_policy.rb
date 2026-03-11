# frozen_string_literal: true

class WorkOrderPolicy < ApplicationPolicy
  # Role slugs used in the organization
  # org_admin, maintenance_manager, technician, storekeeper, auditor

  def index?
    true
  end

  def show?
    true
  end

  def create?
    user.has_any_role?(:org_admin, :maintenance_manager, :technician)
  end

  def new?
    create?
  end

  def update?
    user.has_any_role?(:org_admin, :maintenance_manager) || record.assigned_to == user || record.requester == user
  end

  def edit?
    update?
  end

  def destroy?
    user.has_role?(:org_admin) || record.requester == user
  end

  def assign?
    user.has_any_role?(:org_admin, :maintenance_manager)
  end

  def start?
    return false unless record.respond_to?(:may_start?) && record.may_start?
    user.has_any_role?(:org_admin, :maintenance_manager, :technician)
  end

  def pause?
    return false unless record.respond_to?(:may_pause?) && record.may_pause?
    user.has_any_role?(:org_admin, :maintenance_manager) || record.assigned_to == user
  end

  def resume?
    return false unless record.respond_to?(:may_resume?) && record.may_resume?
    user.has_any_role?(:org_admin, :maintenance_manager) || record.assigned_to == user
  end

  def complete?
    return false unless record.respond_to?(:may_complete?) && record.may_complete?
    user.has_any_role?(:org_admin, :maintenance_manager) || record.assigned_to == user
  end

  def verify?
    return false unless record.respond_to?(:may_verify?) && record.may_verify?
    user.has_any_role?(:org_admin, :maintenance_manager)
  end

  def close?
    return false unless record.respond_to?(:may_close?) && record.may_close?
    user.has_any_role?(:org_admin, :maintenance_manager)
  end

  def reopen?
    user.has_any_role?(:org_admin, :maintenance_manager)
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.has_role?(:org_admin) || user.has_role?(:maintenance_manager)
        scope.all
      elsif user.has_role?(:technician)
        scope.where(assigned_to: user).or(scope.where(requester: user))
      else
        scope.none
      end
    end
  end
end

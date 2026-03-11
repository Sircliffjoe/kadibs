# frozen_string_literal: true

class PreventiveMaintenanceSchedulePolicy < ApplicationPolicy
  # Role slugs: org_admin, maintenance_manager, technician, storekeeper, auditor

  def index?
    true
  end

  def show?
    true
  end

  def create?
    user.has_any_role?(:org_admin, :maintenance_manager)
  end

  def new?
    create?
  end

  def update?
    user.has_any_role?(:org_admin, :maintenance_manager)
  end

  def edit?
    update?
  end

  def destroy?
    user.has_role?(:org_admin)
  end

  def calendar?
    true
  end

  def upcoming?
    true
  end

  def generate_work_order?
    user.has_any_role?(:org_admin, :maintenance_manager)
  end

  def activate?
    user.has_any_role?(:org_admin, :maintenance_manager)
  end

  def deactivate?
    user.has_any_role?(:org_admin, :maintenance_manager)
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all
    end
  end
end

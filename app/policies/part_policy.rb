# frozen_string_literal: true

class PartPolicy < ApplicationPolicy
  # Role slugs: org_admin, maintenance_manager, technician, storekeeper, auditor

  def index?
    true
  end

  def show?
    true
  end

  def create?
    super_admin? || user.has_any_role?(:org_admin, :maintenance_manager, :storekeeper)
  end

  def new?
    create?
  end

  def update?
    super_admin? || user.has_any_role?(:org_admin, :maintenance_manager, :storekeeper)
  end

  def edit?
    update?
  end

  def destroy?
    super_admin? || user.has_role?(:org_admin)
  end

  def low_stock?
    true
  end

  def stock_levels?
    true
  end

  def movement_history?
    super_admin? || user.has_any_role?(:org_admin, :maintenance_manager, :storekeeper, :auditor)
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all
    end
  end
end

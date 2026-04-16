# frozen_string_literal: true

class SupplierPolicy < ApplicationPolicy
  # Role slugs: org_admin, maintenance_manager, technician, storekeeper, finance

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

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all
    end
  end
end

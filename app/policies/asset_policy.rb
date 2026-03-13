# frozen_string_literal: true

class AssetPolicy < ApplicationPolicy
  # Role slugs: org_admin, maintenance_manager, technician, storekeeper, auditor

  def index?
    true
  end

  def show?
    true
  end

  def create?
    super_admin? || user.has_any_role?(:org_admin, :maintenance_manager)
  end

  def new?
    create?
  end

  def update?
    super_admin? || user.has_any_role?(:org_admin, :maintenance_manager)
  end

  def edit?
    update?
  end

  def destroy?
    super_admin? || user.has_role?(:org_admin)
  end

  def history?
    true
  end

  def work_orders?
    true
  end

  def transfer?
    super_admin? || user.has_any_role?(:org_admin, :maintenance_manager)
  end

  def update_meter?
    super_admin? || user.has_any_role?(:org_admin, :maintenance_manager, :technician)
  end

  def import?
    super_admin? || user.has_any_role?(:org_admin, :maintenance_manager)
  end

  def process_import?
    import?
  end

  def export?
    super_admin? || user.has_any_role?(:org_admin, :maintenance_manager, :auditor)
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all
    end
  end
end

# frozen_string_literal: true

class PurchaseRequisitionPolicy < ApplicationPolicy
  # Role slugs: org_admin, maintenance_manager, technician, storekeeper, auditor

  def index?
    true
  end

  def show?
    true
  end

  def create?
    super_admin? || user.has_any_role?(:org_admin, :maintenance_manager, :storekeeper, :technician)
  end

  def new?
    create?
  end

  def update?
    return false unless record.status.in?(%w[draft pending])
    super_admin? || user.has_any_role?(:org_admin, :maintenance_manager, :storekeeper) || record.created_by == user
  end

  def edit?
    update?
  end

  def destroy?
    return false unless record.status == "draft"
    super_admin? || user.has_role?(:org_admin) || record.created_by == user
  end

  def submit?
    return false unless record.status == "draft"
    super_admin? || record.created_by == user || user.has_any_role?(:org_admin, :maintenance_manager)
  end

  def approve?
    return false unless record.status == "pending"
    super_admin? || user.has_any_role?(:org_admin, :maintenance_manager)
  end

  def reject?
    return false unless record.status == "pending"
    super_admin? || user.has_any_role?(:org_admin, :maintenance_manager)
  end

  def mark_ordered?
    return false unless record.status == "approved"
    super_admin? || user.has_any_role?(:org_admin, :maintenance_manager, :storekeeper)
  end

  def receive?
    return false unless record.status == "ordered"
    super_admin? || user.has_any_role?(:org_admin, :maintenance_manager, :storekeeper)
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if super_admin? || user.has_any_role?(:org_admin, :maintenance_manager, :storekeeper, :auditor)
        scope.all
      else
        scope.where(created_by: user)
      end
    end
  end
end

# frozen_string_literal: true

class LocationPolicy < ApplicationPolicy
  # Role slugs: org_admin, maintenance_manager, technician, storekeeper, finance

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

  def children?
    true
  end

  def assets?
    true
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if super_admin?
        scope.all
      else
        scope.all # Currently all users see all locations, but adding consistency
      end
    end
  end
end

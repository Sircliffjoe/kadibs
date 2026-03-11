# frozen_string_literal: true

class LocationPolicy < ApplicationPolicy
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

  def children?
    true
  end

  def assets?
    true
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all
    end
  end
end

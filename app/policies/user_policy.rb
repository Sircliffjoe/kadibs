# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  def index?
    admin? || maintenance_manager?
  end

  def show?
    admin? || maintenance_manager? || record == user
  end

  def create?
    admin?
  end

  def update?
    admin? || record == user
  end

  def destroy?
    admin? && record != user # Can't delete yourself
  end

  def manage_roles?
    admin?
  end

  def impersonate?
    super_admin?
  end

  def activate?
    admin?
  end

  def deactivate?
    admin? && record != user
  end

  def assign_role?
    admin?
  end

  def remove_role?
    admin? && record != user
  end

  class Scope < Scope
    def resolve
      base_scope = super_admin? ? scope.all : scope.where(organization: user.organization)
      base_scope.kept
    end
  end
end

# frozen_string_literal: true

class InspectionPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def create?
    super_admin? || user.admin? || user.manager? || user.technician?
  end

  def update?
    super_admin? || user.admin? || user.manager? || (user.technician? && record.inspector_id == user.id)
  end

  def destroy?
    super_admin? || user.admin? || user.manager?
  end

  def start?
    update?
  end

  def complete?
    update?
  end

  def fail?
    update?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.admin? || user.manager?
        scope.all
      else
        scope.all # Technicians see all for now
      end
    end
  end
end

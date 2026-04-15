# frozen_string_literal: true

class PartCategoryPolicy < ApplicationPolicy
  def index?
    admin?
  end

  def show?
    admin?
  end

  def create?
    admin?
  end

  def update?
    admin?
  end

  def destroy?
    admin?
  end

  class Scope < Scope
    def resolve
      if admin?
        scope.where(organization_id: user.organization_id)
      else
        scope.none
      end
    end
  end
end

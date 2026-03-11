# frozen_string_literal: true

class WorkOrderCommentPolicy < ApplicationPolicy
  def create?
    true
  end

  def destroy?
    record.user == user || user.has_role?(:admin) || user.has_role?(:manager)
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all
    end
  end
end

class NotificationPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      if super_admin?
        scope.all
      else
        scope.where(recipient: user)
      end
    end
  end

  def index?
    true
  end

  def show?
    super_admin? || record.recipient_id == user.id
  end

  def destroy?
    super_admin? || record.recipient_id == user.id
  end

  def mark_read?
    super_admin? || record.recipient_id == user.id
  end

  def mark_all_read?
    true
  end
end

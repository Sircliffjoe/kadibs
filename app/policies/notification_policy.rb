class NotificationPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.where(recipient: user)
    end
  end

  def index?
    true
  end

  def show?
    record.recipient_id == user.id
  end

  def destroy?
    record.recipient_id == user.id
  end

  def mark_read?
    record.recipient_id == user.id
  end

  def mark_all_read?
    true
  end
end

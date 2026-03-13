# frozen_string_literal: true

class ReportPolicy < ApplicationPolicy
  def view?
    super_admin? || user.admin? || user.manager? || user.roles.exists?(name: "technician") # Adjust as needed
  end
end

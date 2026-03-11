# frozen_string_literal: true

class OrganizationsController < ApplicationController
  # Organization management is typically available to all members of the organization
  # but with different permissions. For now, we'll allow all users to view,
  # but authorization might be needed for edit/update later.

  # Skipping pundit for now as we are transitioning from acts_as_tenant
  skip_after_action :verify_authorized
  skip_after_action :verify_policy_scoped

  before_action :set_organization

  def show
  end

  def edit
  end

  def update
    if @organization.update(organization_params)
      redirect_to organization_path, notice: "Organization settings updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def subscription
  end

  def billing
  end

  private

  def set_organization
    @organization = current_organization
  end

  def organization_params
    params.require(:organization).permit(:name, :domain, :phone, :email, :website, :address, :city, :state, :zip_code, :country)
  end
end

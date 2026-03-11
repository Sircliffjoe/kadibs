# frozen_string_literal: true

# Custom Devise registrations controller for organization creation during signup
class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [ :create ]
  before_action :check_registration_availability, only: [ :new, :create ]

  protected

  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [
      :first_name, :last_name, :phone, :organization_name
    ])
  end

  def build_resource(hash = {})
    super

    # If organization_name provided, create a new organization
    organization_name = params.dig(:user, :organization_name)
    if organization_name.present?
      org = Organization.new(
        name: organization_name,
        status: "active",
        plan: "starter",
        trial_ends_at: 14.days.from_now
      )

      if org.save
        resource.organization = org
        # Create default roles for the new organization
        org.create_default_roles! if org.respond_to?(:create_default_roles!)

        # Assign org_admin role to the user who created the organization
        assign_admin_role(resource, org)
      else
        resource.errors.add(:base, "Failed to create organization: #{org.errors.full_messages.join(', ')}")
      end
    end
  end

  def after_sign_up_path_for(resource)
    dashboard_path
  end

  def after_inactive_sign_up_path_for(resource)
    new_user_session_path
  end

  private

  def assign_admin_role(user, org)
    admin_role = org.roles.find_by(slug: "org_admin")
    if admin_role
      user.roles << admin_role unless user.roles.include?(admin_role)
    end
  end

  def check_registration_availability
    if User.exists?
      redirect_to new_user_session_path, alert: "Registration is disabled. Please contact your administrator for an account."
    end
  end
end

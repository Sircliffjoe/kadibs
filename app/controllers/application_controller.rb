# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pundit::Authorization
  include Pagy::Backend

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # ==========================================================================
  # Authentication
  # ==========================================================================
  before_action :authenticate_user!, unless: :skip_authentication?

  # ==========================================================================
  # Devise: Redirect paths
  # ==========================================================================
  before_action :configure_permitted_parameters, if: :devise_controller?

  # ==========================================================================
  # Pundit: Ensure authorization is performed
  # ==========================================================================
  after_action :verify_authorized, unless: :skip_authorization?
  after_action :verify_policy_scoped, if: -> { action_name == "index" && !skip_policy_scope? }

  # ==========================================================================
  # Error Handling
  # ==========================================================================
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  protected

  # Devise: Allow extra params during sign up
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [
      :first_name, :last_name, :phone, :organization_id
    ])
    devise_parameter_sanitizer.permit(:account_update, keys: [
      :first_name, :last_name, :phone, :avatar, :timezone, :locale
    ])
  end

  # Where to redirect after sign in
  def after_sign_in_path_for(resource)
    stored_location_for(resource) || dashboard_path
  end

  # Where to redirect after sign out
  def after_sign_out_path_for(_resource_or_scope)
    root_path
  end

  private

  # Handle Pundit not authorized errors
  def user_not_authorized(exception)
    policy_name = exception.policy.class.to_s.underscore
    message = t("pundit.#{policy_name}.#{exception.query}",
                default: "You are not authorized to perform this action.")

    respond_to do |format|
      format.html do
        flash[:alert] = message
        redirect_back(fallback_location: root_path)
      end
      format.json { render json: { error: message }, status: :forbidden }
      format.turbo_stream do
        flash.now[:alert] = message
        render turbo_stream: turbo_stream.update("flash", partial: "shared/flash")
      end
    end
  end

  # Handle record not found
  def record_not_found
    respond_to do |format|
      format.html do
        flash[:alert] = "The requested record was not found."
        redirect_back(fallback_location: root_path)
      end
      format.json { render json: { error: "Record not found" }, status: :not_found }
    end
  end

  # Skip authentication for certain controllers
  def skip_authentication?
    devise_controller? || controller_name == "pages" || controller_name == "health"
  end

  # Skip Pundit authorization for certain controllers/actions
  def skip_authorization?
    skip_pundit? || action_name == "index"
  end

  # Skip Pundit policy scope for certain controllers/actions
  def skip_policy_scope?
    skip_pundit?
  end

  # Base skip check for Pundit
  def skip_pundit?
    devise_controller? ||
      controller_path.start_with?("rails/") ||
      controller_name == "pages" ||
      controller_name == "health" ||
      controller_name == "dashboard"
  end

  # Current organization - for single company, just get the first/only org
  def current_organization
    @current_organization ||= current_user&.organization
  end
  helper_method :current_organization
end

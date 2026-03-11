# frozen_string_literal: true

class PagesController < ApplicationController
  # Skip authentication and authorization for public pages
  skip_before_action :authenticate_user!, raise: false
  skip_after_action :verify_authorized
  skip_after_action :verify_policy_scoped

  def home
    # Redirect to dashboard if already signed in
    redirect_to dashboard_path if user_signed_in?
  end

  def about
  end

  def services
  end

  def contact
  end

  def privacy
  end

  def terms
  end

  def pricing
  end
end

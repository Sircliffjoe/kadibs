# frozen_string_literal: true

class SettingsController < ApplicationController
  # Skip Pundit - users can always access their own settings
  skip_after_action :verify_authorized
  skip_after_action :verify_policy_scoped
  def index
    @user = current_user
  end

  def update_notifications
    @user = current_user
    if @user.update(notification_params)
      redirect_to settings_path, notice: "Notification preferences updated."
    else
      render :index, status: :unprocessable_entity
    end
  end

  def update_password
    @user = current_user
    if @user.update_with_password(password_params)
      bypass_sign_in(@user)
      redirect_to settings_path, notice: "Password updated successfully."
    else
      render :index, status: :unprocessable_entity
    end
  end

  private

  def notification_params
    params.require(:user).permit(:email_notifications, :push_notifications, :sms_notifications)
  end

  def password_params
    params.require(:user).permit(:current_password, :password, :password_confirmation)
  end
end

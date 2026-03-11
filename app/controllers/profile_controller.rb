# frozen_string_literal: true

class ProfileController < ApplicationController
  # Skip Pundit - users can always view/edit their own profile
  skip_after_action :verify_authorized
  skip_after_action :verify_policy_scoped
  def show
    @user = current_user
  end

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    if @user.update(profile_params)
      redirect_to profile_path, notice: "Profile updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def profile_params
    params.require(:user).permit(
      :first_name, :last_name, :email, :phone, :job_title, :avatar
    )
  end
end

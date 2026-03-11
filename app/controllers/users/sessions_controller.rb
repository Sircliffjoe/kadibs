# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  # GET /login
  def new
    super
  end

  # POST /login
  def create
    super
  end

  # DELETE /logout
  def destroy
    signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
    set_flash_message!(:notice, :signed_out) if signed_out

    respond_to do |format|
      format.html { redirect_to root_path, status: :see_other }
      format.turbo_stream { redirect_to root_path, status: :see_other }
      format.all { head :no_content }
    end
  end
end

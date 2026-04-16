# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :set_user, only: %i[show edit update destroy activate deactivate work_orders skills assign_role remove_role]

  def index
    authorize User
    @users = policy_scope(User)
              .includes(:roles)
              .order(:last_name, :first_name)

    if params[:search].present?
      @users = @users.where(
        "first_name ILIKE :q OR last_name ILIKE :q OR email ILIKE :q",
        q: "%#{params[:search]}%"
      )
    end

    @users = @users.where(id: UserRole.where(role_id: params[:role]).select(:user_id)) if params[:role].present?

    @pagy, @users = pagy(@users, items: 20)
  end

  def technicians
    authorize User
    technician_role = Role.find_by(name: "technician")
    @users = policy_scope(User)
              .joins(:roles)
              .where(roles: { id: technician_role&.id })
              .order(:last_name, :first_name)

    render :index
  end

  def availability
    authorize User
    # TODO: Implement availability calendar
  end

  def show
    authorize @user
    @recent_work_orders = @user.assigned_work_orders.order(created_at: :desc).limit(10)
  end

  def new
    @user = User.new
    authorize @user
  end

  def edit
    authorize @user
  end

  def create
    @user = User.new(user_params)
    @user.organization = current_organization
    @user.password = "password123"
    @user.password_confirmation = "password123"
    authorize @user

    if @user.save
      redirect_to @user, notice: "User was successfully created with default password: password123"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    authorize @user
    if @user.update(user_params)
      redirect_to @user, notice: "User was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @user
    @user.destroy
    redirect_to users_url, notice: "User was successfully deleted."
  end

  def activate
    authorize @user
    if @user.activate!
      redirect_to @user, notice: "User activated."
    else
      redirect_to @user, alert: "Could not activate user."
    end
  end

  def deactivate
    authorize @user
    if @user.deactivate!
      redirect_to @user, notice: "User deactivated."
    else
      redirect_to @user, alert: "Could not deactivate user."
    end
  end

  def work_orders
    authorize @user
    @work_orders = @user.assigned_work_orders.includes(:asset).order(created_at: :desc)
    @pagy, @work_orders = pagy(@work_orders, items: 20)
  end

  def skills
    authorize @user
    # TODO: Implement skills management
  end

  def assign_role
    authorize @user
    role = Role.find(params[:role_id])

    unless @user.roles.include?(role)
      @user.roles << role
      redirect_to @user, notice: "Role assigned successfully."
    else
      redirect_to @user, alert: "User already has this role."
    end
  end

  def remove_role
    authorize @user
    role = Role.find(params[:role_id])
    @user.roles.delete(role)
    redirect_to @user, notice: "Role removed successfully."
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(
      :email, :first_name, :last_name, :phone, :job_title,
      :department, :employee_id, :timezone, :locale, role_ids: []
    )
  end
end

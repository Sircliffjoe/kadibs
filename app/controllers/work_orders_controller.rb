# frozen_string_literal: true

class WorkOrdersController < ApplicationController
  before_action :set_work_order, only: %i[show edit update destroy assign start pause resume complete verify close reopen]
  before_action :load_form_data, only: %i[new edit create update]

  def index
    authorize WorkOrder
    @work_orders = policy_scope(WorkOrder)
                    .includes(:asset, :assigned_to, :location)
                    .order(created_at: :desc)

    # Filtering
    @work_orders = @work_orders.where(status: params[:status]) if params[:status].present?
    @work_orders = @work_orders.where(priority: params[:priority]) if params[:priority].present?
    @work_orders = @work_orders.where(work_order_type: params[:type]) if params[:type].present?

    # Search
    if params[:search].present?
      @work_orders = @work_orders.where(
        "work_order_number ILIKE :q OR title ILIKE :q OR description ILIKE :q",
        q: "%#{params[:search]}%"
      )
    end

    @pagy, @work_orders = pagy(@work_orders, items: 20)
  end

  def show
    authorize @work_order
    @comments = @work_order.work_order_comments.includes(:user).order(created_at: :desc)
    @parts = @work_order.work_order_parts.includes(:part)
    @labor_entries = @work_order.work_order_labors.includes(:user)
    @checklists = @work_order.work_order_checklists.includes(:items)
  end

  def new
    @work_order = WorkOrder.new
    @work_order.asset_id = params[:asset_id] if params[:asset_id]
    authorize @work_order
  end

  def edit
    authorize @work_order
  end

  def create
    @work_order = WorkOrder.new(work_order_params)
    @work_order.requester = current_user
    @work_order.organization = current_organization
    authorize @work_order

    if @work_order.save
      redirect_to @work_order, notice: "Work order was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    authorize @work_order
    if @work_order.update(work_order_params)
      redirect_to @work_order, notice: "Work order was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @work_order
    @work_order.destroy
    redirect_to work_orders_url, notice: "Work order was successfully deleted."
  end

  # Workflow actions
  def assign
    authorize @work_order
    if @work_order.assign_to(User.find(params[:user_id]))
      redirect_to @work_order, notice: "Work order assigned successfully."
    else
      redirect_to @work_order, alert: "Failed to assign work order."
    end
  end

  def start
    authorize @work_order
    if @work_order.start!(current_user)
      redirect_to @work_order, notice: "Work order started."
    else
      redirect_to @work_order, alert: "Cannot start this work order."
    end
  end

  def pause
    authorize @work_order
    if @work_order.pause!
      redirect_to @work_order, notice: "Work order paused."
    else
      redirect_to @work_order, alert: "Cannot pause this work order."
    end
  end

  def resume
    authorize @work_order
    if @work_order.resume!
      redirect_to @work_order, notice: "Work order resumed."
    else
      redirect_to @work_order, alert: "Cannot resume this work order."
    end
  end

  def complete
    authorize @work_order
    if @work_order.complete!(current_user, params[:completion_notes])
      redirect_to @work_order, notice: "Work order marked as complete."
    else
      redirect_to @work_order, alert: "Cannot complete this work order."
    end
  end

  def verify
    authorize @work_order
    if @work_order.verify!(current_user)
      redirect_to @work_order, notice: "Work order verified."
    else
      redirect_to @work_order, alert: "Cannot verify this work order."
    end
  end

  def close
    authorize @work_order
    if @work_order.close!(current_user)
      redirect_to @work_order, notice: "Work order closed."
    else
      redirect_to @work_order, alert: "Cannot close this work order."
    end
  end

  def reopen
    authorize @work_order
    if @work_order.reopen!(params[:reason])
      redirect_to @work_order, notice: "Work order reopened."
    else
      redirect_to @work_order, alert: "Cannot reopen this work order."
    end
  end

  private

  def set_work_order
    @work_order = WorkOrder.find(params[:id])
  end

  def work_order_params
    params.require(:work_order).permit(
      :title, :description, :work_order_type, :priority, :status, :category,
      :asset_id, :location_id, :assigned_to_id, :supervisor_id, :due_date,
      :scheduled_start, :scheduled_end, :estimated_hours, :instructions, :safety_notes,
      :failure_code_id, :pm_schedule_id, :due_in_value, :due_in_unit
    )
  end

  def load_form_data
    @assets = Asset.order(:name)
    @locations = Location.order(:name)
    @technicians = User.joins(:roles).where(roles: { slug: %w[technician maintenance_manager org_admin] }).distinct.order(:first_name, :last_name)
    @managers = User.joins(:roles).where(roles: { slug: %w[maintenance_manager org_admin] }).distinct.order(:first_name, :last_name)
  end
end

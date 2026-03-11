# frozen_string_literal: true

class PmSchedulesController < ApplicationController
  before_action :set_pm_schedule, only: %i[show edit update destroy generate_work_order activate deactivate]

  def index
    authorize PreventiveMaintenanceSchedule
    @pm_schedules = policy_scope(PreventiveMaintenanceSchedule)
                     .includes(:asset, :default_assignee)
                     .order(next_due_date: :asc)

    if params[:status].present?
      case params[:status]
      when "active"
        @pm_schedules = @pm_schedules.active
      when "inactive"
        @pm_schedules = @pm_schedules.inactive
      end
    end
    @pm_schedules = @pm_schedules.where(asset_id: params[:asset_id]) if params[:asset_id].present?

    if params[:search].present?
      @pm_schedules = @pm_schedules.where(
        "name ILIKE :q OR description ILIKE :q",
        q: "%#{params[:search]}%"
      )
    end

    @pagy, @pm_schedules = pagy(@pm_schedules, items: 20)
  end

  def calendar
    authorize PreventiveMaintenanceSchedule
    @pm_schedules = policy_scope(PreventiveMaintenanceSchedule)
                     .active
                     .where(next_due_date: Date.current.beginning_of_month..Date.current.end_of_month + 1.month)
                     .includes(:asset)
  end

  def upcoming
    authorize PreventiveMaintenanceSchedule
    @pm_schedules = policy_scope(PreventiveMaintenanceSchedule)
                     .active
                     .where("next_due_date <= ?", 14.days.from_now)
                     .order(next_due_date: :asc)

    @pagy, @pm_schedules = pagy(@pm_schedules, items: 20)
    render :index
  end

  def show
    authorize @pm_schedule
    @occurrences = @pm_schedule.pm_occurrences.order(scheduled_date: :desc).limit(10)
    @generated_work_orders = WorkOrder.where(pm_schedule: @pm_schedule).order(created_at: :desc).limit(10)
  end

  def new
    @pm_schedule = PreventiveMaintenanceSchedule.new
    @pm_schedule.asset_id = params[:asset_id] if params[:asset_id]
    authorize @pm_schedule
  end

  def edit
    authorize @pm_schedule
  end

  def create
    @pm_schedule = PreventiveMaintenanceSchedule.new(pm_schedule_params)
    @pm_schedule.organization = current_organization
    @pm_schedule.created_by = current_user
    authorize @pm_schedule

    if @pm_schedule.save
      redirect_to @pm_schedule, notice: "PM Schedule was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    authorize @pm_schedule
    if @pm_schedule.update(pm_schedule_params)
      redirect_to @pm_schedule, notice: "PM Schedule was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @pm_schedule
    @pm_schedule.destroy
    redirect_to pm_schedules_url, notice: "PM Schedule was successfully deleted."
  end

  def generate_work_order
    authorize @pm_schedule
    work_order = @pm_schedule.generate_work_order!

    if work_order.persisted?
      redirect_to work_order, notice: "Work order generated successfully."
    else
      redirect_to @pm_schedule, alert: "Could not generate work order."
    end
  end

  def activate
    authorize @pm_schedule
    if @pm_schedule.activate!
      redirect_to @pm_schedule, notice: "PM Schedule activated."
    else
      redirect_to @pm_schedule, alert: "Could not activate schedule."
    end
  end

  def deactivate
    authorize @pm_schedule
    if @pm_schedule.deactivate!
      redirect_to @pm_schedule, notice: "PM Schedule deactivated."
    else
      redirect_to @pm_schedule, alert: "Could not deactivate schedule."
    end
  end

  private

  def set_pm_schedule
    @pm_schedule = PreventiveMaintenanceSchedule.find(params[:id])
  end

  def pm_schedule_params
    params.require(:preventive_maintenance_schedule).permit(
      :name, :description, :asset_id, :location_id, :default_assignee_id,
      :priority, :frequency_type, :frequency_value, :frequency_unit,
      :meter_based, :meter_interval, :next_due_date, :estimated_hours,
      :pm_template_id, :checklist_template
    )
  end
end

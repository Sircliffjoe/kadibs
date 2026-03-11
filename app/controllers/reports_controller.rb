# frozen_string_literal: true

class ReportsController < ApplicationController
  def dashboard
    authorize :report, :view?
    # KPI Data Stubs
    @kpis = {
      open_work_orders: WorkOrder.where(status: [ "open", "in_progress" ]).count,
      overdue_work_orders: WorkOrder.where("due_date < ? AND status != ?", Date.current, "completed").count,
      low_stock_items: Part.low_stock.count,
      pending_requisitions: PurchaseRequisition.where(status: "pending_approval").count
    }
  end

  def work_orders
    authorize :report, :view?
    @work_orders = WorkOrder.includes(:asset, :assigned_to).order(created_at: :desc)

    @status_counts = WorkOrder.group(:status).count
    @priority_counts = WorkOrder.group(:priority).count

    # Filter by date range if provided (TODO: add date picker)
    if params[:start_date].present? && params[:end_date].present?
      @work_orders = @work_orders.where(created_at: params[:start_date]..params[:end_date])
    end

    @pagy, @work_orders = pagy(@work_orders, items: 50)
  end

  def assets
    authorize :report, :view?
    @assets = Asset.includes(:location, :asset_category).order(:name)
    @total_assets = Asset.count
    @total_value = Asset.sum(:current_value)
    @status_counts = Asset.group(:status).count
    @category_counts = Asset.group(:asset_category_id).count
    @age_distribution = Asset.group("EXTRACT(YEAR FROM current_date) - year_manufactured").count

    @pagy, @assets = pagy(@assets, items: 50)
  end

  def inventory
    authorize :report, :view?
    @parts = Part.includes(:default_stock_location).order(:name)
    @total_value = Part.sum("quantity_on_hand * average_cost")
    @low_stock_count = Part.low_stock.count
    @stock_outs = Part.where(quantity_on_hand: 0).count

    @pagy, @parts = pagy(@parts, items: 50)
  end

  def costs
    authorize :report, :view?
    # Simplified cost analysis for now
    @maintenance_costs = WorkOrder.where.not(total_cost: nil).sum(:total_cost)
    @purchase_costs = PurchaseRequisition.where(status: "received").sum(:total_amount)

    # Monthly breakdown (last 12 months)
    @monthly_costs = WorkOrder.where("created_at > ?", 1.year.ago)
                              .group_by_month(:created_at)
                              .sum(:total_cost)
  end

  def technicians
    authorize :report, :view?
    @technicians = User.joins(:roles).where(roles: { name: "technician" }).distinct

    @tech_stats = @technicians.map do |tech|
      {
        user: tech,
        completed_wos: WorkOrder.where(assigned_to: tech, status: "completed").count,
        avg_completion_time: 0, # Placeholder for meaningful calculation
        open_wos: WorkOrder.where(assigned_to: tech, status: [ "open", "in_progress" ]).count
      }
    end
  end

  def compliance
    authorize :report, :view?
    @pm_schedules = PreventiveMaintenanceSchedule.all
    @total_compliance = 0
    # Calculate overall compliance rate
    if @pm_schedules.any?
      @total_compliance = @pm_schedules.average(:compliance_rate)
    end

    @overdue_pms = PmOccurrence.overdue.count
  end

  def kpis
    authorize :report, :view?
  end

  def custom
    authorize :report, :view?
  end

  def export
    authorize :report, :view?
    # TODO: Implement export
    redirect_to reports_dashboard_path, notice: "Export started."
  end
end

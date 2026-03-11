# frozen_string_literal: true

class DashboardController < ApplicationController
  def index
    @work_orders_count = work_orders_scope.count
    @open_work_orders = work_orders_scope.where(status: %w[open assigned in_progress]).count
    @overdue_work_orders = work_orders_scope.where(status: %w[open assigned in_progress])
                                            .where("due_date < ?", Date.current).count
    @completed_today = work_orders_scope.where(status: "completed")
                                        .where("completed_at >= ?", Date.current.beginning_of_day).count

    # Asset statistics
    @assets_count = assets_scope.count
    @critical_assets = assets_scope.where(criticality: "critical").count
    @assets_under_maintenance = assets_scope.where(status: "under_maintenance").count

    # PM Statistics
    @upcoming_pms = pm_schedules_scope.active
                                      .where("next_due_date <= ?", 7.days.from_now)
                                      .count

    # Inventory alerts
    @low_stock_items = parts_scope.joins(:inventory_items)
                                  .where("inventory_items.quantity <= parts.minimum_stock")
                                  .distinct.count

    # Recent work orders
    @recent_work_orders = work_orders_scope.order(created_at: :desc).limit(5)

    # Recent activity (from PaperTrail if enabled)
    @recent_activity = PaperTrail::Version.where(
      item_type: %w[WorkOrder Asset Part]
    ).order(created_at: :desc).limit(10)
  end

  private

  def work_orders_scope
    WorkOrder.all
  rescue
    WorkOrder.none
  end

  def assets_scope
    Asset.all
  rescue
    Asset.none
  end

  def pm_schedules_scope
    PreventiveMaintenanceSchedule.all
  rescue
    PreventiveMaintenanceSchedule.none
  end

  def parts_scope
    Part.all
  rescue
    Part.none
  end
end

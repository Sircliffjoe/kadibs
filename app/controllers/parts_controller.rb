# frozen_string_literal: true

class PartsController < ApplicationController
  before_action :set_part, only: %i[show edit update destroy stock_levels movement_history]

  def index
    authorize Part
    @parts = policy_scope(Part)
              .includes(:part_category, :preferred_supplier, :inventory_items)
              .order(name: :asc)

    # Filtering
    @parts = @parts.where(part_category_id: params[:category]) if params[:category].present?
    @parts = @parts.where(preferred_supplier_id: params[:supplier]) if params[:supplier].present?

    # Search
    if params[:search].present?
      @parts = @parts.where(
        "part_number ILIKE :q OR name ILIKE :q OR description ILIKE :q",
        q: "%#{params[:search]}%"
      )
    end

    @pagy, @parts = pagy(@parts, items: 20)
  end

  def low_stock
    authorize Part
    @parts = policy_scope(Part)
              .joins(:inventory_items)
              .where("inventory_items.quantity <= parts.minimum_stock")
              .distinct
              .includes(:part_category, :preferred_supplier)

    @pagy, @parts = pagy(@parts, items: 20)
    render :index
  end

  def show
    authorize @part
    @inventory_items = @part.inventory_items.includes(:warehouse)
    @recent_movements = StockMovement.where(part: @part).order(created_at: :desc).limit(10)
  end

  def new
    @part = Part.new
    authorize @part
  end

  def edit
    authorize @part
  end

  def create
    @part = Part.new(part_params)
    @part.organization = current_organization
    authorize @part

    if @part.save
      redirect_to @part, notice: "Part was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    authorize @part
    if @part.update(part_params)
      redirect_to @part, notice: "Part was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @part
    @part.destroy
    redirect_to parts_url, notice: "Part was successfully deleted."
  end

  def stock_levels
    authorize @part
    @inventory_items = @part.inventory_items.includes(:warehouse, :stock_location)
  end

  def movement_history
    authorize @part
    @movements = StockMovement.where(part: @part).order(created_at: :desc)
    @pagy, @movements = pagy(@movements, items: 20)
  end

  private

  def set_part
    @part = Part.find(params[:id])
  end

  def part_params
    params.require(:part).permit(
      :part_number, :name, :description, :part_category_id, :preferred_supplier_id,
      :unit_of_measure, :unit_cost, :minimum_stock, :reorder_level,
      :lead_time_days, :barcode
    )
  end
end

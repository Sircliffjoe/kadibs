# frozen_string_literal: true

class WarehousesController < ApplicationController
  before_action :set_warehouse, only: %i[show edit update destroy]

  def index
    authorize Warehouse
    @warehouses = policy_scope(Warehouse).includes(:location).order(:name)

    @pagy, @warehouses = pagy(@warehouses, items: 20)
  end

  def show
    authorize @warehouse
    @stock_locations = @warehouse.stock_locations.order(:name)
    @inventory_items = @warehouse.inventory_items.includes(:part).order(:created_at)
  end

  def new
    @warehouse = Warehouse.new
    authorize @warehouse
  end

  def edit
    authorize @warehouse
  end

  def create
    @warehouse = Warehouse.new(warehouse_params)
    @warehouse.organization = current_organization
    authorize @warehouse

    if @warehouse.save
      redirect_to @warehouse, notice: "Warehouse was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    authorize @warehouse
    if @warehouse.update(warehouse_params)
      redirect_to @warehouse, notice: "Warehouse was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @warehouse
    @warehouse.destroy
    redirect_to warehouses_url, notice: "Warehouse was successfully deleted."
  end

  private

  def set_warehouse
    @warehouse = Warehouse.find(params[:id])
  end

  def warehouse_params
    params.require(:warehouse).permit(:name, :description, :location_id, :manager_id, :code, :default_warehouse)
  end
end

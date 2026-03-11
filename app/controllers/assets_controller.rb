# frozen_string_literal: true

class AssetsController < ApplicationController
  before_action :set_asset, only: %i[show edit update destroy history work_orders transfer update_meter]

  def index
    authorize Asset
    @assets = policy_scope(Asset)
               .includes(:asset_category, :location)
               .order(created_at: :desc)

    # Filtering
    @assets = @assets.where(status: params[:status]) if params[:status].present?
    @assets = @assets.where(asset_category_id: params[:category]) if params[:category].present?
    @assets = @assets.where(location_id: params[:location]) if params[:location].present?
    @assets = @assets.where(criticality: params[:criticality]) if params[:criticality].present?

    # Search
    if params[:search].present?
      @assets = @assets.where(
        "code ILIKE :q OR name ILIKE :q OR serial_number ILIKE :q OR manufacturer ILIKE :q",
        q: "%#{params[:search]}%"
      )
    end

    @pagy, @assets = pagy(@assets, items: 20)
  end

  def show
    authorize @asset
    @work_orders = @asset.work_orders.order(created_at: :desc).limit(10)
    @meter_readings = @asset.meter_readings.order(reading_date: :desc).limit(10)
    @maintenance_history = @asset.work_orders.completed.order(completed_at: :desc).limit(5)
  end

  def new
    @asset = Asset.new
    @asset.location_id = params[:location_id] if params[:location_id]
    authorize @asset
  end

  def edit
    authorize @asset
  end

  def create
    @asset = Asset.new(asset_params)
    @asset.organization = current_organization
    authorize @asset

    if @asset.save
      redirect_to @asset, notice: "Asset was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    authorize @asset
    if @asset.update(asset_params)
      redirect_to @asset, notice: "Asset was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @asset
    @asset.destroy
    redirect_to assets_url, notice: "Asset was successfully deleted."
  end

  def history
    authorize @asset
    @versions = @asset.versions.order(created_at: :desc)
  end

  def work_orders
    authorize @asset
    @work_orders = @asset.work_orders.includes(:assigned_to).order(created_at: :desc)
  end

  def transfer
    authorize @asset
    new_location = Location.find(params[:location_id])

    if @asset.transfer_to(new_location, current_user, params[:notes])
      redirect_to @asset, notice: "Asset transferred successfully."
    else
      redirect_to @asset, alert: "Failed to transfer asset."
    end
  end

  def update_meter
    authorize @asset
    reading = @asset.meter_readings.new(
      value: params[:value],
      reading_date: Time.current,
      recorded_by: current_user,
      meter_type: params[:meter_type] || "hours"
    )

    if reading.save
      redirect_to @asset, notice: "Meter reading updated."
    else
      redirect_to @asset, alert: "Failed to update meter reading."
    end
  end

  # Collection routes
  def import
    authorize Asset
  end

  def process_import
    authorize Asset
    # TODO: Implement CSV import
    redirect_to assets_path, notice: "Import functionality coming soon."
  end

  def export
    authorize Asset
    @assets = policy_scope(Asset).includes(:asset_category, :location)

    respond_to do |format|
      format.csv do
        send_data generate_csv, filename: "assets-#{Date.current}.csv"
      end
    end
  end

  private

  def set_asset
    @asset = Asset.find(params[:id])
  end

  def asset_params
    params.require(:asset).permit(
      :name, :code, :description, :asset_category_id, :location_id,
      :status, :criticality, :manufacturer, :model, :serial_number,
      :purchase_date, :purchase_price, :warranty_end_date, :useful_life_years,
      :parent_asset_id, :barcode, :qr_code_data
    )
  end

  def generate_csv
    require "csv"
    CSV.generate(headers: true) do |csv|
      csv << [ "Code", "Name", "Category", "Location", "Status", "Manufacturer", "Model" ]
      @assets.each do |asset|
        csv << [
          asset.code, asset.name, asset.asset_category&.name,
          asset.location&.name, asset.status, asset.manufacturer, asset.model
        ]
      end
    end
  end
end

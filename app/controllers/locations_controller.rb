# frozen_string_literal: true

class LocationsController < ApplicationController
  before_action :set_location, only: %i[show edit update destroy children assets]

  def index
    authorize Location
    @locations = policy_scope(Location)
                  .includes(:parent)
                  .order(:name)

    if params[:search].present?
      @locations = @locations.where(
        "name ILIKE :q OR address ILIKE :q",
        q: "%#{params[:search]}%"
      )
    end

    @pagy, @locations = pagy(@locations, items: 20)
  end

  def show
    authorize @location
    @assets = @location.assets.includes(:asset_category).limit(10)
    @child_locations = @location.children.order(:name)
  end

  def new
    @location = Location.new
    @location.parent_id = params[:parent_id] if params[:parent_id]
    authorize @location
  end

  def edit
    authorize @location
  end

  def create
    @location = Location.new(location_params)
    @location.organization = current_organization
    authorize @location

    if @location.save
      redirect_to @location, notice: "Location was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    authorize @location
    if @location.update(location_params)
      redirect_to @location, notice: "Location was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @location
    @location.destroy
    redirect_to locations_url, notice: "Location was successfully deleted."
  end

  def children
    authorize @location
    @children = @location.children.order(:name)
  end

  def assets
    authorize @location
    @assets = @location.assets.includes(:asset_category).order(:name)
    @pagy, @assets = pagy(@assets, items: 20)
  end

  private

  def set_location
    @location = Location.find(params[:id])
  end

  def location_params
    params.require(:location).permit(
      :name, :location_type, :description, :address, :city, :state,
      :postal_code, :country, :latitude, :longitude, :parent_id
    )
  end
end

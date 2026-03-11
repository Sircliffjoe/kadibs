# frozen_string_literal: true

class InspectionsController < ApplicationController
  before_action :set_inspection, only: %i[show edit update destroy start complete fail toggle_item]

  def index
    authorize Inspection
    @inspections = policy_scope(Inspection).includes(:asset, :inspector).order(created_at: :desc)

    if params[:status].present?
      @inspections = @inspections.where(status: params[:status])
    end

    @pagy, @inspections = pagy(@inspections, items: 20)
  end

  def show
    authorize @inspection
  end

  def new
    @inspection = Inspection.new
    @inspection.inspection_items.build
    authorize @inspection
  end

  def edit
    authorize @inspection
  end

  def create
    @inspection = Inspection.new(inspection_params)
    @inspection.organization = current_organization
    @inspection.inspector = current_user
    authorize @inspection

    if @inspection.save
      redirect_to @inspection, notice: "Inspection was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    authorize @inspection
    if @inspection.update(inspection_params)
      redirect_to @inspection, notice: "Inspection was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @inspection
    @inspection.discard
    redirect_to inspections_url, notice: "Inspection was successfully deleted."
  end

  def start
    authorize @inspection
    @inspection.start!
    redirect_to @inspection, notice: "Inspection started."
  end

  def complete
    authorize @inspection
    @inspection.complete!
    redirect_to @inspection, notice: "Inspection completed."
  end

  def fail
    authorize @inspection
    @inspection.fail!
    redirect_to @inspection, alert: "Inspection marked as failed."
  end

  def toggle_item
    authorize @inspection, :update?
    item = @inspection.inspection_items.find(params[:item_id])
    item.update!(checked: !item.checked)
    redirect_to @inspection
  end

  private

  def set_inspection
    @inspection = Inspection.find(params[:id])
  end

  def inspection_params
    params.require(:inspection).permit(
      :title, :description, :asset_id, :work_order_id, :scheduled_date, :status,
      inspection_items_attributes: [ :id, :description, :checked, :notes, :_destroy ]
    )
  end
end

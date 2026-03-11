# frozen_string_literal: true

class PurchaseRequisitionsController < ApplicationController
  before_action :set_purchase_requisition, only: %i[show edit update destroy submit approve reject mark_ordered receive]

  def index
    authorize PurchaseRequisition
    @purchase_requisitions = policy_scope(PurchaseRequisition)
                              .includes(:supplier, :requested_by)
                              .order(created_at: :desc)

    @purchase_requisitions = @purchase_requisitions.where(status: params[:status]) if params[:status].present?

    @pagy, @purchase_requisitions = pagy(@purchase_requisitions, items: 20)
  end

  def show
    authorize @purchase_requisition
    @items = @purchase_requisition.purchase_requisition_items.includes(:part)
  end

  def new
    @purchase_requisition = PurchaseRequisition.new
    authorize @purchase_requisition
  end

  def edit
    authorize @purchase_requisition
  end

  def create
    @purchase_requisition = PurchaseRequisition.new(purchase_requisition_params)
    @purchase_requisition.organization = current_organization
    @purchase_requisition.requested_by = current_user
    authorize @purchase_requisition

    if @purchase_requisition.save
      redirect_to @purchase_requisition, notice: "Purchase requisition was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    authorize @purchase_requisition
    if @purchase_requisition.update(purchase_requisition_params)
      redirect_to @purchase_requisition, notice: "Purchase requisition was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @purchase_requisition
    @purchase_requisition.destroy
    redirect_to purchase_requisitions_url, notice: "Purchase requisition was successfully deleted."
  end

  # Workflow actions
  def submit
    authorize @purchase_requisition
    if @purchase_requisition.submit!
      redirect_to @purchase_requisition, notice: "Purchase requisition submitted for approval."
    else
      redirect_to @purchase_requisition, alert: "Could not submit requisition."
    end
  end

  def approve
    authorize @purchase_requisition
    if @purchase_requisition.approve!(current_user)
      redirect_to @purchase_requisition, notice: "Purchase requisition approved."
    else
      redirect_to @purchase_requisition, alert: "Could not approve requisition."
    end
  end

  def reject
    authorize @purchase_requisition
    if @purchase_requisition.reject!(current_user, params[:reason])
      redirect_to @purchase_requisition, notice: "Purchase requisition rejected."
    else
      redirect_to @purchase_requisition, alert: "Could not reject requisition."
    end
  end

  def mark_ordered
    authorize @purchase_requisition
    if @purchase_requisition.mark_ordered!(params[:po_number])
      redirect_to @purchase_requisition, notice: "Marked as ordered."
    else
      redirect_to @purchase_requisition, alert: "Could not mark as ordered."
    end
  end

  def receive
    authorize @purchase_requisition
    if @purchase_requisition.receive!(current_user)
      redirect_to @purchase_requisition, notice: "Items received and inventory updated."
    else
      redirect_to @purchase_requisition, alert: "Could not receive items."
    end
  end

  private

  def set_purchase_requisition
    @purchase_requisition = PurchaseRequisition.find(params[:id])
  end

  def purchase_requisition_params
    params.require(:purchase_requisition).permit(
      :supplier_id, :notes, :required_date, :shipping_address,
      purchase_requisition_items_attributes: [ :id, :part_id, :quantity_requested, :unit_price, :notes, :_destroy ]
    )
  end
end

# frozen_string_literal: true

class SuppliersController < ApplicationController
  before_action :set_supplier, only: %i[show edit update destroy]

  def index
    authorize Supplier
    @suppliers = policy_scope(Supplier).order(:name)

    if params[:search].present?
      @suppliers = @suppliers.where(
        "name ILIKE :q OR contact_name ILIKE :q OR email ILIKE :q",
        q: "%#{params[:search]}%"
      )
    end

    @pagy, @suppliers = pagy(@suppliers, items: 20)
  end

  def show
    authorize @supplier
    @parts = @supplier.parts.order(:name).limit(10)
  end

  def new
    @supplier = Supplier.new
    authorize @supplier
  end

  def edit
    authorize @supplier
  end

  def create
    @supplier = Supplier.new(supplier_params)
    @supplier.organization = current_organization
    authorize @supplier

    if @supplier.save
      redirect_to @supplier, notice: "Vendor was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    authorize @supplier
    if @supplier.update(supplier_params)
      redirect_to @supplier, notice: "Vendor was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @supplier
    @supplier.destroy
    redirect_to suppliers_url, notice: "Vendor was successfully deleted."
  end

  private

  def set_supplier
    @supplier = Supplier.find(params[:id])
  end

  def supplier_params
    params.require(:supplier).permit(
      :name, :contact_name, :email, :phone, :address, :city, :state,
      :postal_code, :country, :website, :notes, :status
    )
  end
end

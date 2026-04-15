# frozen_string_literal: true

class AssetCategoriesController < ApplicationController
  before_action :set_asset_category, only: %i[show edit update destroy]

  def index
    authorize AssetCategory
    @asset_categories = policy_scope(AssetCategory)
                         .includes(:parent)
                         .order(:name)

    @pagy, @asset_categories = pagy(@asset_categories, items: 20)
  end

  def show
    authorize @asset_category
    @assets = @asset_category.assets.includes(:location).limit(10)
    @children = @asset_category.children.order(:name)
  end

  def new
    @asset_category = AssetCategory.new(parent_id: params[:parent_id])
    authorize @asset_category
  end

  def edit
    authorize @asset_category
  end

  def create
    @asset_category = AssetCategory.new(asset_category_params)
    @asset_category.organization = current_organization
    authorize @asset_category

    if @asset_category.save
      redirect_to asset_categories_path, notice: "Asset category was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    authorize @asset_category
    if @asset_category.update(asset_category_params)
      redirect_to asset_categories_path, notice: "Asset category was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @asset_category
    if @asset_category.assets.any? || @asset_category.children.any?
      redirect_to asset_categories_path, alert: "Cannot delete category that has equipment or sub-categories. Please move them first."
    else
      @asset_category.discard
      redirect_to asset_categories_path, notice: "Asset category was successfully deleted."
    end
  end

  private

  def set_asset_category
    @asset_category = AssetCategory.find(params[:id])
  end

  def asset_category_params
    params.require(:asset_category).permit(:name, :code, :description, :parent_id)
  end
end

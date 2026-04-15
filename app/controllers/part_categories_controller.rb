# frozen_string_literal: true

class PartCategoriesController < ApplicationController
  before_action :set_part_category, only: %i[show edit update destroy]

  def index
    authorize PartCategory
    @part_categories = policy_scope(PartCategory)
                        .includes(:parent)
                        .order(:name)

    @pagy, @part_categories = pagy(@part_categories, items: 20)
  end

  def show
    authorize @part_category
    @parts = @part_category.parts.limit(10)
    @children = @part_category.children.order(:name)
  end

  def new
    @part_category = PartCategory.new(parent_id: params[:parent_id])
    authorize @part_category
  end

  def edit
    authorize @part_category
  end

  def create
    @part_category = PartCategory.new(part_category_params)
    @part_category.organization = current_organization
    authorize @part_category

    if @part_category.save
      redirect_to part_categories_path, notice: "Part category was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    authorize @part_category
    if @part_category.update(part_category_params)
      redirect_to part_categories_path, notice: "Part category was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @part_category
    if @part_category.parts.any? || @part_category.children.any?
      redirect_to part_categories_path, alert: "Cannot delete category that has parts or sub-categories. Please move them first."
    else
      @part_category.destroy
      redirect_to part_categories_path, notice: "Part category was successfully deleted."
    end
  end

  private

  def set_part_category
    @part_category = PartCategory.find(params[:id])
  end

  def part_category_params
    params.require(:part_category).permit(:name, :code, :description, :parent_id)
  end
end

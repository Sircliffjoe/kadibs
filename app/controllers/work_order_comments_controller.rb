# frozen_string_literal: true

class WorkOrderCommentsController < ApplicationController
  before_action :set_work_order, only: [ :create ]
  before_action :set_comment, only: [ :destroy ]

  def create
    @comment = @work_order.work_order_comments.build(comment_params)
    @comment.user = current_user

    if @comment.save
      redirect_to @work_order, notice: "Comment added successfully."
    else
      redirect_to @work_order, alert: "Failed to add comment: #{@comment.errors.full_messages.join(', ')}"
    end
  end

  def destroy
    authorize @comment
    work_order = @comment.work_order

    if @comment.destroy
      redirect_to work_order, notice: "Comment deleted."
    else
      redirect_to work_order, alert: "Failed to delete comment."
    end
  end

  private

  def set_work_order
    @work_order = WorkOrder.find(params[:work_order_id])
    authorize @work_order, :show?
  end

  def set_comment
    @comment = WorkOrderComment.find(params[:id])
  end

  def comment_params
    if params.key?(:work_order_comment)
      params.require(:work_order_comment).permit(:content)
    else
      params.permit(:content)
    end
  end
end

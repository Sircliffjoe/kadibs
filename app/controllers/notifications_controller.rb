class NotificationsController < ApplicationController
  before_action :set_notification, only: %i[show destroy mark_read]

  def index
    # Using policy_scope ensures users only see their own notifications
    @notifications = policy_scope(Notification).recent.includes(:actor, :notifiable)
    @pagy, @notifications = pagy(@notifications)
  end

  def show
    authorize @notification
    @notification.mark_as_read!

    if @notification.notifiable
      redirect_to @notification.notifiable
    else
      redirect_to notifications_path
    end
  end

  def destroy
    authorize @notification
    @notification.destroy
    redirect_to notifications_path, notice: "Notification removed."
  end

  def mark_read
    authorize @notification
    @notification.mark_as_read!
    redirect_back(fallback_location: notifications_path)
  end

  def mark_all_read
    authorize Notification, :mark_all_read?
    current_user.notifications.unread.update_all(read_at: Time.current)
    redirect_to notifications_path, notice: "All notifications marked as read."
  end

  private

  def set_notification
    @notification = Notification.find(params[:id])
  end
end

class AddNotificationPreferencesToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :email_notifications, :boolean
    add_column :users, :push_notifications, :boolean
    add_column :users, :sms_notifications, :boolean
  end
end

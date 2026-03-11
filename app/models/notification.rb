class Notification < ApplicationRecord
  # Associations
  belongs_to :recipient, class_name: "User"
  belongs_to :actor, class_name: "User", optional: true
  belongs_to :notifiable, polymorphic: true
  belongs_to :organization

  # Scopes
  scope :unread, -> { where(read_at: nil) }
  scope :read, -> { where.not(read_at: nil) }
  scope :recent, -> { order(created_at: :desc) }

  # Methods
  def read?
    read_at.present?
  end

  def mark_as_read!
    update(read_at: Time.current)
  end
end

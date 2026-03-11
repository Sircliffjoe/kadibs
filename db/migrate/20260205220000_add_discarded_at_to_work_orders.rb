# frozen_string_literal: true

class AddDiscardedAtToWorkOrders < ActiveRecord::Migration[8.0]
  def change
    add_column :work_orders, :discarded_at, :datetime
    add_index :work_orders, :discarded_at
  end
end

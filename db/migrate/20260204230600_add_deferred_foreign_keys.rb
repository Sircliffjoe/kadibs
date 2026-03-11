# frozen_string_literal: true

class AddDeferredForeignKeys < ActiveRecord::Migration[8.0]
  def change
    # Add work_order FK to meter_readings
    add_foreign_key :meter_readings, :work_orders, column: :work_order_id
    add_index :meter_readings, :work_order_id

    # Add work_order FK to stock_movements
    add_foreign_key :stock_movements, :work_orders, column: :work_order_id
    add_index :stock_movements, :work_order_id

    # Add work_order FK to purchase_requisitions
    add_foreign_key :purchase_requisitions, :work_orders, column: :work_order_id
    add_index :purchase_requisitions, :work_order_id
  end
end

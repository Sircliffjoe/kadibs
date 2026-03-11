class AddShippingAddressToPurchaseRequisitions < ActiveRecord::Migration[8.1]
  def change
    add_column :purchase_requisitions, :shipping_address, :text
  end
end

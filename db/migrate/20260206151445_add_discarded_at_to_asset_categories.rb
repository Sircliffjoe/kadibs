class AddDiscardedAtToAssetCategories < ActiveRecord::Migration[8.1]
  def change
    add_column :asset_categories, :discarded_at, :datetime
    add_index :asset_categories, :discarded_at
  end
end

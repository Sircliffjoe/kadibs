class RenameNotesToDescriptionInAssets < ActiveRecord::Migration[8.1]
  def change
    rename_column :assets, :notes, :description
  end
end

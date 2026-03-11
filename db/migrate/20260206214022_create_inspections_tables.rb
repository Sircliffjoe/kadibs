class CreateInspectionsTables < ActiveRecord::Migration[8.0]
  def change
    create_table :inspections do |t|
      t.references :organization, null: false, foreign_key: true
      t.references :asset, foreign_key: true
      t.references :work_order, foreign_key: true
      t.references :inspector, foreign_key: { to_table: :users }

      t.string :title, null: false
      t.text :description
      t.string :status, default: "pending", null: false
      t.date :scheduled_date
      t.datetime :completed_at
      t.datetime :discarded_at

      t.timestamps
    end
    add_index :inspections, :discarded_at

    create_table :inspection_items do |t|
      t.references :inspection, null: false, foreign_key: true
      t.string :description, null: false
      t.boolean :checked, default: false
      t.string :notes
      t.integer :position

      t.timestamps
    end
  end
end

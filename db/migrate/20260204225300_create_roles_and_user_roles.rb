# frozen_string_literal: true

class CreateRolesAndUserRoles < ActiveRecord::Migration[8.0]
  def change
    # =======================================================================
    # Roles Table
    # =======================================================================
    create_table :roles do |t|
      t.references :organization, null: false, foreign_key: true

      t.string :name, null: false
      t.string :slug, null: false
      t.text :description

      # Permissions stored as JSON for flexibility
      # Format: { "assets": ["read", "create", "update"], "work_orders": ["read", "create"] }
      t.jsonb :permissions, default: {}

      # System roles cannot be deleted or modified
      t.boolean :system_role, default: false

      t.timestamps
    end

    add_index :roles, [ :organization_id, :slug ], unique: true
    add_index :roles, [ :organization_id, :name ]
    add_index :roles, :system_role

    # =======================================================================
    # User-Role Join Table
    # =======================================================================
    create_table :user_roles do |t|
      t.references :user, null: false, foreign_key: true
      t.references :role, null: false, foreign_key: true

      # Optional: assigned by
      t.references :assigned_by, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :user_roles, [ :user_id, :role_id ], unique: true
  end
end

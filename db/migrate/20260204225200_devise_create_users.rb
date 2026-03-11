# frozen_string_literal: true

class DeviseCreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      # =======================================================================
      # Organization (Multi-tenancy)
      # =======================================================================
      t.references :organization, null: false, foreign_key: true

      # =======================================================================
      # Profile Information
      # =======================================================================
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :employee_id
      t.string :phone
      t.string :job_title
      t.string :department
      t.string :avatar

      # System flags
      t.boolean :super_admin, default: false
      t.boolean :active, default: true

      # =======================================================================
      # Devise: Database authenticatable
      # =======================================================================
      t.string :email, null: false
      t.string :encrypted_password, null: false, default: ""

      # =======================================================================
      # Devise: Recoverable
      # =======================================================================
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      # =======================================================================
      # Devise: Rememberable
      # =======================================================================
      t.datetime :remember_created_at

      # =======================================================================
      # Devise: Trackable
      # =======================================================================
      t.integer  :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip
      t.string   :last_sign_in_ip

      # =======================================================================
      # Devise: Confirmable
      # =======================================================================
      t.string   :confirmation_token
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at
      t.string   :unconfirmed_email

      # =======================================================================
      # Devise: Lockable
      # =======================================================================
      t.integer  :failed_attempts, default: 0, null: false
      t.string   :unlock_token
      t.datetime :locked_at

      # =======================================================================
      # Timezone & Preferences
      # =======================================================================
      t.string :timezone
      t.string :locale, default: 'en'
      t.jsonb :preferences, default: {}

      # =======================================================================
      # Soft Delete
      # =======================================================================
      t.datetime :discarded_at

      t.timestamps null: false
    end

    # Indexes for Devise
    add_index :users, :email
    add_index :users, :reset_password_token, unique: true
    add_index :users, :confirmation_token,   unique: true
    add_index :users, :unlock_token,         unique: true

    # Unique email per organization (multi-tenant)
    add_index :users, [ :organization_id, :email ], unique: true

    # Other useful indexes
    add_index :users, [ :organization_id, :employee_id ], unique: true, where: "employee_id IS NOT NULL"
    add_index :users, :discarded_at
    add_index :users, :super_admin
    add_index :users, :active
  end
end

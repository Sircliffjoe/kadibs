# frozen_string_literal: true

class CreateOrganizations < ActiveRecord::Migration[8.0]
  def change
    create_table :organizations do |t|
      # Core identification
      t.string :name, null: false
      t.string :slug, null: false, index: { unique: true }

      # Business info
      t.string :industry
      t.string :company_size
      t.string :phone
      t.string :email
      t.string :website

      # Localization
      t.string :timezone, default: 'UTC'
      t.string :date_format, default: '%Y-%m-%d'
      t.string :time_format, default: '%H:%M'
      t.string :currency, default: 'USD'

      # Address (stored as JSON)
      t.jsonb :address, default: {}

      # Settings (flexible configuration)
      t.jsonb :settings, default: {}

      # Branding
      t.string :logo

      # Subscription/Status
      t.string :plan, default: 'starter'
      t.string :status, default: 'active'
      t.datetime :trial_ends_at

      # Soft delete
      t.datetime :discarded_at, index: true

      t.timestamps
    end

    # Add useful indexes
    add_index :organizations, :name
    add_index :organizations, :status
    add_index :organizations, :plan
  end
end

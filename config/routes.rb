# frozen_string_literal: true

Rails.application.routes.draw do
  # ===========================================================================
  # WWW Redirect → kadibs.com (non-www canonical)
  # ===========================================================================
  constraints host: /^www\./ do
    get "(*path)", to: redirect { |params, req|
      "https://kadibs.com/#{params[:path]}#{req.query_string.present? ? "?#{req.query_string}" : ""}"
    }
  end

  # ===========================================================================
  # Devise Authentication
  # ===========================================================================
  devise_for :users, controllers: {
    sessions: "users/sessions",
    passwords: "users/passwords",
    confirmations: "users/confirmations"
  }, path: "", path_names: { sign_in: "login", sign_out: "logout" }

  # ===========================================================================
  # Health Check
  # ===========================================================================
  get "up" => "rails/health#show", as: :rails_health_check

  # ===========================================================================
  # Public Pages
  # ===========================================================================
  root "pages#home"
  get "about", to: "pages#about"
  get "services", to: "pages#services"
  get "contact", to: "pages#contact"
  get "privacy", to: "pages#privacy"
  get "terms", to: "pages#terms"
  get "pricing", to: "pages#pricing"

  # ===========================================================================
  # Authenticated Application Routes
  # ===========================================================================
  # Dashboard
  get "dashboard", to: "dashboard#index", as: :dashboard

  # User Profile & Settings
  get "profile", to: "profile#show", as: :profile
  get "profile/edit", to: "profile#edit", as: :edit_profile
  patch "profile", to: "profile#update"
  get "settings", to: "settings#index", as: :settings
  patch "settings/notifications", to: "settings#update_notifications", as: :settings_notifications
  patch "settings/password", to: "settings#update_password", as: :settings_password

  # Module 1: Organization & Locations
  resources :locations do
    member do
      get :children
      get :assets
    end
  end

  # Organization Settings (single resource, not collection)
  resource :organization, only: [ :show, :edit, :update ] do
    get :subscription
    get :billing
  end

  # Module 2: Asset Management
  resources :asset_categories
  resources :assets, path: "equipment" do
    member do
      get :history
      get :work_orders
      post :transfer
      post :update_meter
    end
    collection do
      get :import
      post :process_import
      get :export
    end
  end

  # Module 3: Work Order Management
  resources :work_orders do
    member do
      post :assign
      post :start
      post :pause
      post :resume
      post :complete
      post :verify
      post :close
      post :reopen
    end
    resources :work_order_labors, shallow: true
    resources :work_order_parts, shallow: true
    resources :work_order_comments, shallow: true, only: [ :create, :destroy ]
    resources :work_order_checklists, shallow: true do
      member do
        post :toggle_item
      end
    end
  end

  # Module 4: Preventive Maintenance
  resources :pm_templates
  resources :pm_schedules, path: "preventive-maintenance" do
    member do
      post :generate_work_order
      post :activate
      post :deactivate
    end
    collection do
      get :calendar
      get :upcoming
    end
  end

  # Module 5: Inventory & Spare Parts
  resources :suppliers
  resources :warehouses do
    resources :stock_locations, shallow: true
  end
  resources :parts do
    member do
      get :stock_levels
      get :movement_history
    end
    collection do
      get :low_stock
    end
  end
  resources :inventory_items, only: [ :index, :show ]
  resources :stock_movements, only: [ :index, :show, :create ]
  resources :purchase_requisitions, path: "purchase-requisitions" do
    member do
      post :submit
      post :approve
      post :reject
      post :mark_ordered
      post :receive
    end
  end

  # Module 6: Workforce & Technician Management
  resources :users do
    member do
      post :activate
      post :deactivate
      get :work_orders
      get :skills
      post :assign_role
      delete :remove_role
    end
    collection do
      get :technicians
      get :availability
    end
  end
  resources :skills
  resources :certifications
  resources :shifts

  # Module 7: Cost & Financial Tracking
  resources :cost_centers, path: "cost-centers"
  resources :budgets do
    member do
      get :vs_actual
    end
  end

  # Module 8: Compliance, Safety & Audit
  resources :safety_procedures, path: "safety-procedures"
  resources :permits_to_work, path: "permits" do
    member do
      post :submit
      post :approve
      post :reject
      post :close
    end
  end
  resources :inspections do
    member do
      post :start
      post :complete
      post :fail
      post :toggle_item
    end
  end
  resources :compliance_checklists, path: "compliance/checklists" do
    resources :compliance_records, shallow: true, only: [ :create, :show ]
  end

  # Module 9: Reporting & Analytics
  namespace :reports do
    get "dashboard"
    get "work_orders"
    get "assets"
    get "inventory"
    get "costs"
    get "technicians"
    get "compliance"
    get "kpis"
    get "custom"
    post "export"
  end

  # Module 10: Notifications
  resources :notifications, only: [ :index, :show, :destroy ] do
    collection do
      post :mark_all_read
    end
    member do
      post :mark_read
    end
  end
  resources :notification_preferences, only: [ :index, :update ]
  resources :alert_configurations, path: "alerts/configure"

  # Meter Readings (for PM)
  resources :meter_readings, only: [ :index, :show, :create ]

  # Failure Codes
  resources :failure_codes, path: "failure-codes"

  # ===========================================================================
  # Admin Namespace (Super Admin / Org Admin)
  # ===========================================================================
  namespace :admin do
    get "dashboard", to: "dashboard#index"
    resources :organizations
    resources :users
    resources :roles do
      member do
        get :permissions
        patch :update_permissions
      end
    end
    resources :audit_logs, only: [ :index, :show ]
    resources :system_settings, only: [ :index, :update ]
  end

  # ===========================================================================
  # API Namespace (v1)
  # ===========================================================================
  namespace :api do
    namespace :v1 do
      # Authentication
      post "auth/login", to: "authentication#login"
      delete "auth/logout", to: "authentication#logout"
      get "auth/me", to: "authentication#me"

      # Core resources
      resources :organizations, only: [ :show, :update ]
      resources :locations
      resources :assets do
        member do
          post :transfer
          post :meter_reading
        end
      end
      resources :work_orders do
        member do
          post :assign
          post :start
          post :complete
          post :close
        end
      end
      resources :pm_schedules, only: [ :index, :show, :create, :update ]
      resources :parts, only: [ :index, :show ]
      resources :inventory_items, only: [ :index, :show ]
      resources :users, only: [ :index, :show ]

      # Webhooks
      resources :webhooks, only: [ :index, :show, :create, :update, :destroy ]
    end
  end

  # ===========================================================================
  # Webhooks (incoming)
  # ===========================================================================
  namespace :webhooks do
    # Add external webhook endpoints here
    # post 'iot/sensor_data', to: 'iot#sensor_data'
  end
end

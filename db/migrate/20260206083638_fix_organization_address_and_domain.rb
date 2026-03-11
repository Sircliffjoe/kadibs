class FixOrganizationAddressAndDomain < ActiveRecord::Migration[8.1]
  def change
    add_column :organizations, :domain, :string

    # Converting address from jsonb to string (street address)
    remove_column :organizations, :address, :jsonb
    add_column :organizations, :address, :string

    # Adding individual address components
    add_column :organizations, :city, :string
    add_column :organizations, :state, :string
    add_column :organizations, :zip_code, :string
    add_column :organizations, :country, :string
  end
end

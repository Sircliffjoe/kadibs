# frozen_string_literal: true

class Supplier < ApplicationRecord
  include Discard::Model

  has_paper_trail

  belongs_to :organization

  has_many :parts, foreign_key: :preferred_supplier_id, dependent: :nullify
  has_many :purchase_requisitions, dependent: :nullify
  has_many :goods_receipts, dependent: :nullify

  default_scope -> { kept }

  scope :active, -> { where(active: true) }
  scope :preferred, -> { where(preferred: true) }

  store_accessor :address, :street, :city, :state, :postal_code, :country, :website

  validates :name, presence: true
  validates :code, uniqueness: { scope: :organization_id, allow_blank: true }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true

  def full_address
    [ street, city, state, postal_code, country ].compact.join(", ")
  end
end

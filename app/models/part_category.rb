# frozen_string_literal: true

class PartCategory < ApplicationRecord
  has_paper_trail

  belongs_to :organization
  belongs_to :parent, class_name: "PartCategory", optional: true

  has_many :children, class_name: "PartCategory", foreign_key: :parent_id, dependent: :nullify
  has_many :parts, dependent: :nullify


  validates :name, presence: true
  validates :code, uniqueness: { scope: :organization_id, allow_blank: true }

  def full_path
    ancestors.reverse.push(self).map(&:name).join(" > ")
  end

  def ancestors
    result = []
    current = parent
    while current
      result << current
      current = current.parent
    end
    result
  end
end

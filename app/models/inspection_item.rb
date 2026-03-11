# frozen_string_literal: true

class InspectionItem < ApplicationRecord
  belongs_to :inspection

  validates :description, presence: true
end

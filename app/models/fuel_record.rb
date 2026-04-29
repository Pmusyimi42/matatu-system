class FuelRecord < ApplicationRecord
  belongs_to :trip
  has_one_attached :pump_photo
  validates :amount, presence: true
  validates :pump_photo, presence: true
end

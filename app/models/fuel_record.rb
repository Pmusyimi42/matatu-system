class FuelRecord < ApplicationRecord
  belongs_to :trip
  has_one_attached :pump_photo
  validates :amount, presence: true
  validates :pump_photo, presence: true
  validate :trip_must_be_active

  def trip_must_be_active
    return if trip&.active?

    errors.add(:base, "Cannot add fuel to a completed trip")
  end
end

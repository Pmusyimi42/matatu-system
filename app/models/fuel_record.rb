class FuelRecord < ApplicationRecord
  include TenantScoped

  belongs_to :trip
  has_one_attached :pump_photo

  before_validation :assign_company

  validates :amount, presence: true
  validate :pump_photo_attached
  validate :trip_must_be_active
  validate :trip_belongs_to_current_company

  private

  def assign_company
    self.company_id ||= trip&.company_id
  end

  def pump_photo_attached
    errors.add(:pump_photo, "is required") unless pump_photo.attached?
  end

  def trip_must_be_active
    return if trip&.active?

    errors.add(:base, "Cannot add fuel to a completed trip")
  end

  def trip_belongs_to_current_company
    return unless trip

    if trip.company_id != Current.company&.id
      errors.add(:trip, "does not belong to your company")
    end
  end
end


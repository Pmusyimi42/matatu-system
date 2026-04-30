class ShiftAssignment < ApplicationRecord
  include TenantScoped

  belongs_to :vehicle
  belongs_to :driver, class_name: "User"

  validates :status, presence: true
  validate :driver_must_be_active
  validate :no_overlapping_shifts, on: :create

  def active?
    status == "active"
  end

  private

  def driver_must_be_active
    return unless driver

    unless driver.active?
      errors.add(:driver, "must be active to receive shifts")
    end
  end

  def no_overlapping_shifts
    return unless driver && start_time && end_time

    overlapping = ShiftAssignment.where(driver_id: driver_id, status: "active")
      .where("start_time < ? AND (end_time IS NULL OR end_time > ?)", end_time, start_time)

    if overlapping.exists?
      errors.add(:base, "Driver has an overlapping shift")
    end
  end
end

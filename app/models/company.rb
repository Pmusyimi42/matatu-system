class Company < ApplicationRecord
  has_many :users, dependent: :destroy
  has_many :vehicles, dependent: :destroy
  has_many :routes, dependent: :destroy
  has_many :trips, dependent: :destroy
  has_many :shift_assignments, dependent: :destroy
  has_many :expense_records, dependent: :destroy
  has_many :fuel_records, dependent: :destroy

  def setup_complete?
    vehicles.any? && routes.any? && users.where(role: "driver").exists?
  end

  def setup_progress
    {
      has_vehicles: vehicles.any?,
      has_routes: routes.any?,
      has_drivers: users.where(role: "driver").exists?,
      complete: setup_complete?
    }
  end
end

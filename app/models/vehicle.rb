class Vehicle < ApplicationRecord
  include TenantScoped

  has_many :shift_assignments
  has_many :trips

  def current_shift
    shift_assignments.find_by(status: "active")
  end

  def current_driver
    current_shift&.driver
  end
end


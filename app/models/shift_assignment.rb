class ShiftAssignment < ApplicationRecord
  include TenantScoped

  belongs_to :vehicle
  belongs_to :driver, class_name: "User"

  validates :status, presence: true

  def active?
    status == "active"
  end
end


class ShiftAssignment < ApplicationRecord
  belongs_to :vehicle
  belongs_to :driver, class_name: "User"

  validates :status, presence: true

  def active?
    status == "active"
  end
end

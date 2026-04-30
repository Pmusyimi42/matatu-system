class User < ApplicationRecord
  has_secure_password

  belongs_to :company
  has_many :shift_assignments, foreign_key: :driver_id, dependent: :destroy
  has_many :assigned_vehicles, through: :shift_assignments, source: :vehicle

  validates :email, presence: true, uniqueness: true
  validates :role, inclusion: { in: %w[admin driver] }
  validates :status, inclusion: { in: %w[active inactive pending] }

  def admin?
    role == "admin"
  end

  def driver?
    role == "driver"
  end

  def active?
    status == "active"
  end

  def can_manage_system?
    admin?
  end

  def current_shift
    shift_assignments.find_by(status: "active")
  end

  def current_vehicle
    current_shift&.vehicle
  end
end

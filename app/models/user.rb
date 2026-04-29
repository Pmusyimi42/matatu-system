class User < ApplicationRecord
  has_secure_password

  has_many :vehicles, foreign_key: :driver_id

  validates :email, presence: true, uniqueness: true

  def admin?
    role == "admin"
  end

  def driver?
    role == "driver" || "admin"
  end
  def active?
    status == "active"
  end
  def can_manage_system?
    role == "admin"
  end
end

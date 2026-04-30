class User < ApplicationRecord
#  include TenantScoped

  has_secure_password

  belongs_to :company
  has_many :vehicles, foreign_key: :driver_id

  validates :email, presence: true, uniqueness: true
  validates :role, inclusion: { in: %w[admin driver] }
  validates :status, inclusion: { in: %w[active inactive pending] }

  def admin?
    role == "admin"
  end

  def driver?
    role == "driver" || role == "admin"
  end

  def active?
    status == "active"
  end

  def can_manage_system?
    admin?
  end
end


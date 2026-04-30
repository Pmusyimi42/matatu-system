class Route < ApplicationRecord
  include TenantScoped

  has_many :trips, dependent: :nullify

  validates :origin, :destination, presence: true
end

class Route < ApplicationRecord
  include TenantScoped

  has_many :trips

  validates :origin, :destination, presence: true
end


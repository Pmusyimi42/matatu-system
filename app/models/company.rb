class Company < ApplicationRecord
  has_many :users
  has_many :vehicles
  has_many :trips
end

# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
# Create a company
# Create a company first (before TenantScoped kicks in)
company = Company.create!(name: "Matatu Express")

# Set Current context for all subsequent TenantScoped models
Current.company = company

# Create admin user
admin = User.create!(
  name: "Admin User",
  email: "admin@matatu.com",
  password: "password123",
  password_confirmation: "password123",
  role: "admin",
  status: "active",
  company: company
)

# Create a driver
driver = User.create!(
  name: "John Driver",
  email: "driver@matatu.com",
  password: "password123",
  password_confirmation: "password123",
  role: "driver",
  status: "active",
  company: company
)

# Create a vehicle
vehicle = Vehicle.create!(
  plate_number: "KBC 123A",
  capacity: 14,
  status: "active",
  company: company
)

# Create a route
route = Route.create!(
  origin: "Nairobi CBD",
  destination: "Westlands",
  company: company
)

# Create a shift assignment
shift = ShiftAssignment.create!(
  vehicle: vehicle,
  driver: driver,
  status: "active",
  company: company
)

# Create an active trip
trip = Trip.create!(
  vehicle: vehicle,
  route: route,
  start_time: Time.current,
  status: "active",
  company: company
)

Current.company = nil

puts "Seed data created successfully!"
puts "Admin: admin@matatu.com / password123"
puts "Driver: driver@matatu.com / password123"


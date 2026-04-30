module Trips
  class CreateService
    def initialize(company:, user:, params:)
      @company = company
      @user = user
      @params = params
    end

    def call
      vehicle = @company.vehicles.find(@params[:vehicle_id])
      route   = @company.routes.find(@params[:route_id])

      shift = vehicle.shift_assignments.find_by(status: "active")

      raise StandardError, "No active shift for this vehicle" if shift.nil?

      @company.trips.create!(
        vehicle: vehicle,
        route: route,
        start_time: Time.current,
        status: "active"
      )
    end
  end
end

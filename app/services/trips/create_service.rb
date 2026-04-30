module Trips
  class CreateService
    def initialize(company:, user:, params:)
      @company = company
      @user = user
      @params = params
    end

    def call
      vehicle = @company.vehicles.find(@params[:vehicle_id])
      route = @company.routes.find(@params[:route_id])

      unless @user.admin?
        shift = vehicle.shift_assignments.find_by(driver_id: @user.id, status: "active")
        raise StandardError, "You are not assigned to this vehicle" if shift.nil?
      end

      @company.trips.create!(
        vehicle: vehicle,
        route: route,
        driver: @user,
        start_time: Time.current,
        status: "active"
      )
    end
  end
end

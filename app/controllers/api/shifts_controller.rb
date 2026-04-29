class Api::ShiftsController < ApplicationController
  before_action :require_admin
  def create
    vehicle = Vehicle.find(params[:vehicle_id])
    driver = User.find(params[:driver_id])

    # prevent multiple active shifts for vehicle
    if vehicle.shift_assignments.where(status: "active").exists?
      return render json: { error: "Vehicle already has active shift" }, status: :unprocessable_entity
    end

    # prevent driver double assignment
    if driver.shift_assignments.where(status: "active").exists?
      return render json: { error: "Driver already on active shift" }, status: :unprocessable_entity
    end

    shift = ShiftAssignment.create!(
      vehicle: vehicle,
      driver: driver,
      start_time: Time.current,
      status: "active"
    )

    render json: shift, status: :created
  end

  def end_shift
    shift = ShiftAssignment.find(params[:id])
    shift.update(status: "ended", end_time: Time.current)

    render json: { message: "Shift ended" }
  end
  def require_admin
    unless current_user&.admin?
      render json: { error: "Access denied" }, status: :forbidden
    end
  end
end

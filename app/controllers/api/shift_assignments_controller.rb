class Api::ShiftAssignmentsController < ApplicationController
  before_action :set_shift, only: [:show, :update, :destroy]
  before_action :require_admin, only: [:update, :destroy]

  def index
    shifts = if Current.user.admin?
      Current.company.shift_assignments.includes(:vehicle, :driver)
    else
      Current.user.shift_assignments.includes(:vehicle)
    end

    render json: shifts.as_json(include: [:vehicle, :driver])
  end

  def show
    authorize!(@shift)
    render json: @shift.as_json(include: [:vehicle, :driver])
  end

  def create
    vehicle = Current.company.vehicles.find(shift_params[:vehicle_id])

    if Current.user.admin?
      driver = Current.company.users.find(shift_params[:driver_id])
    else
      driver = Current.user
    end

    shift = Current.company.shift_assignments.new(shift_params)
    shift.vehicle = vehicle
    shift.driver = driver

    # Auto-set times for driver self-assignment
    if !Current.user.admin?
      shift.start_time ||= Time.current
      shift.end_time ||= 12.hours.from_now
    end

    if shift.save
      render json: shift, status: :created
    else
      render json: shift.errors, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Vehicle or driver not found" }, status: :not_found
  end

  def update
    if @shift.update(shift_params)
      render json: @shift
    else
      render json: @shift.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @shift.update(status: "inactive")
    render json: { message: "Shift ended" }
  end

  private

  def set_shift
    @shift = if Current.user.admin?
      Current.company.shift_assignments.find(params[:id])
    else
      Current.user.shift_assignments.find(params[:id])
    end
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Shift not found" }, status: :not_found
  end

  def shift_params
    params.require(:shift_assignment).permit(:vehicle_id, :driver_id, :start_time, :end_time, :status)
  end

  def require_admin
    unless Current.user&.admin?
      render json: { error: "Admin access required" }, status: :forbidden
    end
  end
end

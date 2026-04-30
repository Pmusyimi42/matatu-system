class Api::VehiclesController < ApplicationController
  before_action :require_admin, only: [:create, :update, :destroy]

  def index
    vehicles = Current.company.vehicles.includes(:shift_assignments)
    render json: vehicles.as_json(methods: :current_driver)
  end

  def show
    vehicle = Current.company.vehicles.find(params[:id])
    render json: vehicle.as_json(methods: :current_driver)
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Vehicle not found" }, status: :not_found
  end

  def create
    vehicle = Current.company.vehicles.new(vehicle_params)
    vehicle.status = "active"

    if vehicle.save
      render json: vehicle, status: :created
    else
      render json: vehicle.errors, status: :unprocessable_entity
    end
  end

  def update
    vehicle = Current.company.vehicles.find(params[:id])

    if vehicle.update(vehicle_params)
      render json: vehicle
    else
      render json: vehicle.errors, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Vehicle not found" }, status: :not_found
  end

  def destroy
    vehicle = Current.company.vehicles.find(params[:id])
    vehicle.update(status: "inactive")

    render json: { message: "Vehicle deactivated (not deleted)" }
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Vehicle not found" }, status: :not_found
  end

  private

  def vehicle_params
    params.require(:vehicle).permit(:plate_number, :capacity, :status, :driver_id)
  end

  def require_admin
    unless Current.user&.admin?
      render json: { error: "Admin access required" }, status: :forbidden
    end
  end
end

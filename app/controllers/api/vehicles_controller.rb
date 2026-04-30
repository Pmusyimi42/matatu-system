class Api::VehiclesController < ApplicationController
  def index
    vehicles = Vehicle.all

    render json: vehicles.as_json(methods: :current_driver)
  end

  def show
    vehicle = Vehicle.find(params[:id])

    render json: vehicle.as_json(methods: :current_driver)
  end

  def create
    vehicle = Vehicle.new(vehicle_params)
    vehicle.status = "active"

    if vehicle.save
      render json: vehicle, status: :created
    else
      render json: vehicle.errors, status: :unprocessable_entity
    end
  end

  def update
    vehicle = Vehicle.find(params[:id])

    if vehicle.update(vehicle_params)
      render json: vehicle
    else
      render json: vehicle.errors, status: :unprocessable_entity
    end
  end

  def destroy
    vehicle = Vehicle.find(params[:id])
    vehicle.update(status: "inactive")

    render json: { message: "Vehicle deactivated (not deleted)" }
  end

  private

  def vehicle_params
    params.require(:vehicle).permit(:plate_number, :capacity, :status, :driver_id)
  end
end


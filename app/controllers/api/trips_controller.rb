class Api::TripsController < ApplicationController
  def create
  vehicle = Vehicle.find(params[:trip][:vehicle_id])
  route = Route.find(params[:trip][:route_id])

  active_shift = vehicle.shift_assignments.find_by(status: "active")
  return render json: { error: "No active shift for vehicle" }, status: :unprocessable_entity if active_shift.nil?

  trip = Trip.new(
    vehicle: vehicle,
    route: route,
    start_time: Time.current,
    status: "active"
  )

  if trip.save
    render json: trip, status: :created
  else
    render json: trip.errors.full_messages, status: :unprocessable_entity
  end
end

  # END TRIP
  def end_trip
  trip = Trip.find(params[:id])

  if params[:cash_proof_photo].blank?
    return render json: { error: "Delivery photo is required" }, status: :unprocessable_entity
  end

  trip.cash_collected = params[:trip][:cash_collected]
  trip.end_time = Time.current
  trip.status = "completed"

  trip.cash_proof_photo.attach(params[:cash_proof_photo])

  if trip.save
    render json: { message: "Trip closed successfully", trip: trip }
  else
    render json: trip.errors.full_messages, status: :unprocessable_entity
  end
end

  # VIEW TRIPS
  def index
    trips = Trip.all.order(created_at: :desc)
    render json: trips
  end

  def show
    trip = Trip.find(params[:id])
    render json: trip
  end
end

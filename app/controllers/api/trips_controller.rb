class Api::TripsController < ApplicationController
  def create
    vehicle = Vehicle.find(params[:trip][:vehicle_id])
    route = Route.find(params[:trip][:route_id])

    active_shift = vehicle.shift_assignments.find_by(status: "active", driver: Current.user)
    return render json: { error: "No active shift for this vehicle" }, status: :unprocessable_entity if active_shift.nil?

    trip = Trip.new(
      vehicle: vehicle,
      route: route,
      start_time: Time.current,
      status: "active"
    )

    if trip.save
      render json: trip, status: :created
    else
      render json: { errors: trip.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def end_trip
    trip = Trip.find(params[:id])

    if params[:cash_proof_photo].blank?
      return render json: { error: "Delivery photo is required" }, status: :unprocessable_entity
    end

    trip.complete_trip!(
      cash_collected: params[:trip][:cash_collected],
      cash_proof_photo: params[:cash_proof_photo]
    )

    render json: { message: "Trip closed successfully", trip: trip }
  rescue ActiveRecord::RecordInvalid => e
    render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
  end

  def index
    trips = Trip.order(created_at: :desc)
    render json: trips
  end

  def show
    trip = Trip.find(params[:id])
    render json: trip
  end

  def summary
    trip = Trip.find(params[:id])

    render json: TripSummaryService.new(trip).call, status: :ok
  end
end


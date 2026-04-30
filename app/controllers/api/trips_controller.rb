class Api::TripsController < ApplicationController
  before_action :set_trip, only: [:show, :end_trip, :summary]

  def create
    trip = Trips::CreateService.new(
      company: Current.company,
      user: Current.user,
      params: trip_params
    ).call

    render json: trip, status: :created

  rescue StandardError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def end_trip
    authorize!(@trip)

    Trips::EndService.new(
      company: Current.company,
      trip: @trip,
      params: end_trip_params
    ).call

    render json: { message: "Trip closed successfully" }

  rescue StandardError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def show
    authorize!(@trip)
    render json: @trip
  end

  def index
    render json: Current.company.trips.order(created_at: :desc)
  end

  def summary
    render json: Trips::SummaryService.new(trip: @trip).call
  end

  private

  def set_trip
    @trip = Current.company.trips.find(params[:id])
  end

  def trip_params
    params.require(:trip).permit(:vehicle_id, :route_id, :cash_collected)
  end

  def end_trip_params
    params.permit(:cash_collected, :cash_proof_photo)
  end
end

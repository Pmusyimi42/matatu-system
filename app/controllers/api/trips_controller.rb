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
    render json: @trip.as_json(
      methods: [:duration_minutes],
      include: [:vehicle, :route, :driver, :fuel_records, :expense_records]
    )
  end

  def index
    trips = if Current.user.admin?
      Current.company.trips
    else
      Current.company.trips.where(driver_id: Current.user.id)
    end

    render json: trips.order(created_at: :desc).as_json(
      methods: [:duration_minutes],
      include: [:vehicle, :route]
    )
  end

  def summary
    authorize!(@trip)
    render json: Trips::SummaryService.new(trip: @trip).call
  end

  def monthly_summary
    year = params[:year]&.to_i || Time.current.year
    month = params[:month]&.to_i || Time.current.month

    summary = if Current.user.admin?
      Trips::MonthlySummaryService.new(company: Current.company, year: year, month: month).call
    else
      Trips::MonthlySummaryService.new(
        company: Current.company,
        year: year,
        month: month,
        driver: Current.user
      ).call
    end

    render json: summary
  end

  private

  def set_trip
    scope = Current.user.admin? ? Current.company.trips : Current.company.trips.where(driver_id: Current.user.id)
    @trip = scope.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Trip not found" }, status: :not_found
  end

  def trip_params
    params.require(:trip).permit(:vehicle_id, :route_id, :cash_collected)
  end

  def end_trip_params
    params.permit(:cash_collected, :cash_proof_photo)
  end
end

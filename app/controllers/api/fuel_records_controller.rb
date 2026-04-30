class Api::FuelRecordsController < ApplicationController
  before_action :set_trip

  def create
    return render json: { error: "Cannot add fuel to a completed trip" }, status: :unprocessable_entity if @trip.completed?

    fuel_record = @trip.fuel_records.new(fuel_record_params)
    fuel_record.pump_photo.attach(fuel_record_params[:pump_photo]) if fuel_record_params[:pump_photo].present?

    fuel_record.save!
    render json: fuel_record, status: :created
  rescue ActiveRecord::RecordInvalid => e
    render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
  end

  def index
    fuel_records = @trip.fuel_records.order(created_at: :desc)
    render json: fuel_records
  end

  private

  def set_trip
    scope = Current.user.admin? ? Current.company.trips : Current.company.trips.where(driver_id: Current.user.id)
    @trip = scope.find(params[:trip_id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Trip not found" }, status: :not_found
  end

  def fuel_record_params
    params.require(:fuel_record).permit(:amount, :pump_photo)
  end
end

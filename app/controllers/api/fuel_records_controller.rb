class Api::FuelRecordsController < ApplicationController
  def create
  trip = Trip.find(fuel_record_params[:trip_id])

  if trip.completed?
    return render json: { error: "Cannot add fuel to a completed trip" }, status: :unprocessable_entity
  end

  fuel_record = trip.fuel_records.new(
    amount: fuel_record_params[:amount]
  )

  fuel_record.pump_photo.attach(fuel_record_params[:pump_photo])

  fuel_record.save!

  render json: fuel_record, status: :created
end
def index
  fuel_records = FuelRecord.all.order(created_at: :desc)
  render json: fuel_records
end

private

def fuel_record_params
  params.require(:fuel_record).permit(:trip_id, :amount)
end
end

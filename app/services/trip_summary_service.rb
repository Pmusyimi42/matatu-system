class TripSummaryService
  def initialize(trip)
    @trip = trip
  end

  def call
    {
      trip_id: @trip.id,
      status: @trip.status,
      start_time: @trip.start_time,
      end_time: @trip.end_time,

      vehicle: vehicle_info,
      route: route_info,

      cash_collected: cash_collected.to_f,
      fuel_total: fuel_total.to_f,
      expense_total: expense_total.to_f,
      net_balance: net_balance.to_f
    }
  end

  private

  def vehicle_info
  {
    id: @trip.vehicle&.id,
    plate_number: @trip.vehicle&.plate_number,
    capacity: @trip.vehicle&.capacity,
    status: @trip.vehicle&.status
  }
end

  def route_info
  return nil unless @trip.route

  {
    id: @trip.route.id,
    origin: @trip.route.origin,
    destination: @trip.route.destination
  }
end
  
  def fuel_total
  @fuel_total ||= @trip.fuel_records.sum(:amount)
end

def expense_total
  @expense_total ||= @trip.expense_records.sum(:amount)
end

  def cash_collected
    @trip.cash_collected.to_f
  end

  def net_balance
  @trip.cash_collected.to_f - fuel_total - expense_total
end
end

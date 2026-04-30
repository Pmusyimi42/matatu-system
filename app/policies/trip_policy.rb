class TripPolicy
  attr_reader :user, :trip

  def initialize(user, trip)
    @user = user
    @trip = trip
  end

  def show?
    same_company?
  end

  def create?
    same_company?
  end

  def end_trip?
    same_company? && (user.admin? || trip_driver_id == user.id)
  end

  def summary?
    same_company?
  end

  private

  def same_company?
    user.company_id == trip.company_id
  end

  def trip_driver_id
    # Driver is accessed through the vehicle's current driver
    # or through the active shift assignment
    trip.vehicle&.driver_id || 
      ShiftAssignment.find_by(vehicle_id: trip.vehicle_id, status: 'active')&.driver_id
  end
end

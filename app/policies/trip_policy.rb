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
    same_company? && (user.admin? || user.driver?)
  end

  def end_trip?
    same_company? && (user.admin? || trip_driver?)
  end

  def summary?
    same_company? && (user.admin? || trip_driver?)
  end

  private

  def same_company?
    user.company_id == trip.company_id
  end

  def trip_driver?
    trip.driver_id == user.id
  end
end

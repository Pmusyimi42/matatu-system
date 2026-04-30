module Trips
  class MonthlySummaryService
    def initialize(company:, year: nil, month: nil, driver: nil)
      @company = company
      @year = year || Time.current.year
      @month = month || Time.current.month
      @driver = driver
    end

    def call
      {
        period: "#{@year}-#{@month.to_s.rjust(2, '0')}",
        total_trips: trips.count,
        completed_trips: trips.completed.count,
        active_trips: trips.active.count,
        total_cash_collected: trips.completed.sum(:cash_collected).to_f,
        total_fuel: total_fuel.to_f,
        total_expenses: total_expenses.to_f,
        net_revenue: net_revenue.to_f,
        avg_trip_duration: avg_trip_duration,
        top_routes: top_routes,
        by_driver: by_driver
      }
    end

    private

    def trips
      scope = @company.trips.where(
        start_time: date_range.begin..date_range.end
      )

      scope = scope.where(driver_id: @driver.id) if @driver
      scope
    end

    def date_range
      Time.zone.local(@year, @month).all_month
    end

    def total_fuel
      FuelRecord.where(trip_id: trips.completed.select(:id)).sum(:amount)
    end

    def total_expenses
      ExpenseRecord.where(trip_id: trips.completed.select(:id)).sum(:amount)
    end

    def net_revenue
      trips.completed.sum(:cash_collected) - total_fuel - total_expenses
    end

    def avg_trip_duration
      completed = trips.completed.where.not(end_time: nil)
      return 0 if completed.none?

      total = completed.sum("EXTRACT(EPOCH FROM (end_time - start_time))") / 60
      (total / completed.count).round
    end

    def top_routes
      trips.completed.group(:route_id)
        .select("route_id, COUNT(*) as trip_count, SUM(cash_collected) as revenue")
        .order("trip_count DESC")
        .limit(5)
        .map do |r|
          route = Route.find_by(id: r.route_id)
          {
            route: route ? "#{route.origin} → #{route.destination}" : "Unknown",
            trips: r.trip_count,
            revenue: r.revenue.to_f
          }
        end
    end

    def by_driver
      return {} unless @driver.nil?

      trips.completed.group(:driver_id)
        .select("driver_id, COUNT(*) as trip_count, SUM(cash_collected) as revenue")
        .map do |d|
          driver = User.find_by(id: d.driver_id)
          {
            name: driver&.name || "Unknown",
            trips: d.trip_count,
            revenue: d.revenue.to_f
          }
        end
    end
  end
end

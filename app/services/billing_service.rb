class BillingService
  def initialize(company:, month: nil)
    @company = company
    @month = month || Time.current.beginning_of_month
  end

  def generate_invoice
    {
      company: @company.name,
      billing_period: @month.strftime("%B %Y"),
      generated_at: Time.current,
      line_items: line_items,
      totals: totals
    }
  end

  def driver_statements
    @company.users.where(role: "driver", status: "active").map do |driver|
      {
        driver_id: driver.id,
        driver_name: driver.name,
        period: @month.strftime("%B %Y"),
        trips: driver_trips(driver).count,
        cash_collected: driver_trips(driver).sum(:cash_collected).to_f,
        fuel_cost: driver_fuel(driver).to_f,
        expenses: driver_expenses(driver).to_f,
        net_due: net_due(driver).to_f
      }
    end
  end

  private

  def trips_scope
    @company.trips.where(start_time: @month.all_month)
  end

  def driver_trips(driver)
    trips_scope.where(driver_id: driver.id, status: "completed")
  end

  def driver_fuel(driver)
    FuelRecord.where(trip_id: driver_trips(driver).select(:id)).sum(:amount)
  end

  def driver_expenses(driver)
    ExpenseRecord.where(trip_id: driver_trips(driver).select(:id)).sum(:amount)
  end

  def net_due(driver)
    driver_trips(driver).sum(:cash_collected) - driver_fuel(driver) - driver_expenses(driver)
  end

  def line_items
    [
      { description: "Completed Trips", quantity: trips_scope.completed.count, amount: trips_scope.completed.sum(:cash_collected).to_f },
      { description: "Total Fuel", quantity: fuel_records.count, amount: total_fuel.to_f },
      { description: "Total Expenses", quantity: expense_records.count, amount: total_expenses.to_f }
    ]
  end

  def totals
    {
      gross_revenue: trips_scope.completed.sum(:cash_collected).to_f,
      total_costs: (total_fuel + total_expenses).to_f,
      net_revenue: (trips_scope.completed.sum(:cash_collected) - total_fuel - total_expenses).to_f
    }
  end

  def fuel_records
    FuelRecord.where(trip_id: trips_scope.completed.select(:id))
  end

  def expense_records
    ExpenseRecord.where(trip_id: trips_scope.completed.select(:id))
  end

  def total_fuel
    fuel_records.sum(:amount)
  end

  def total_expenses
    expense_records.sum(:amount)
  end
end

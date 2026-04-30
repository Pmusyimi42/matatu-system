class Api::ExpenseRecordsController < ApplicationController
  before_action :set_trip, only: [:create, :index]

  def create
    expense = @trip.expense_records.new(expense_params)

    if expense.save
      render json: expense, status: :created
    else
      render json: { errors: expense.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def index
    expenses = @trip.expense_records.order(created_at: :desc)
    render json: expenses
  end

  private

  def set_trip
    scope = Current.user.admin? ? Current.company.trips : Current.company.trips.where(driver_id: Current.user.id)
    @trip = scope.find(params[:trip_id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Trip not found" }, status: :not_found
  end

  def expense_params
    params.require(:expense_record).permit(:description, :amount)
  end
end

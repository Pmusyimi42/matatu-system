class Api::ExpenseRecordsController < ApplicationController
  def create
    trip = Trip.find(params[:trip_id])

    expense = trip.expense_records.new(
      description: params[:description],
      amount: params[:amount]
    )

    if expense.save
      render json: expense, status: :created
    else
      render json: expense.errors, status: :unprocessable_entity
    end
  end

  def index
    render json: ExpenseRecord.order(created_at: :desc)
  end
end


class Api::ShiftAssignmentsController < ApplicationController
  class Api::ShiftAssignmentsController < ApplicationController
  def create
    shift = ShiftAssignment.new(shift_params)

    if shift.save
      render json: shift, status: :created
    else
      render json: shift.errors, status: :unprocessable_entity
    end
  end

  private

  def shift_params
    params.require(:shift_assignment).permit(:vehicle_id, :driver_id, :start_time, :end_time, :status)
  end
end
end

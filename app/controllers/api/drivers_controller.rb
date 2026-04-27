class Api::DriversController < ApplicationController
  def create
    driver = User.new(driver_params)
    driver.role = "driver"
    driver.status = "pending"

    if driver.save
      render json: {
        message: "Driver registered successfully. Awaiting admin approval."
      }, status: :created
    else
      render json: driver.errors, status: :unprocessable_entity
    end
  end
  def approve
    driver = User.find(params[:id])

    if driver.role == "driver"
      driver.update(status: "active")
      render json: { message: "Driver approved successfully" }
    else
      render json: { error: "Not a driver" }, status: :bad_request
    end
end

  private

  def driver_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end

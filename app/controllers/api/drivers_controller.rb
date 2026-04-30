class Api::DriversController < ApplicationController
  before_action :require_admin, only: [:create, :approve]

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

    unless driver.role == "driver"
      return render json: { error: "Not a driver" }, status: :bad_request
    end

    if driver.update(status: "active")
      render json: { message: "Driver approved successfully" }
    else
      render json: driver.errors, status: :unprocessable_entity
    end
  end

  private

  def driver_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

  def require_admin
    unless Current.user&.admin?
      render json: { error: "Admin access required" }, status: :forbidden
    end
  end
end


class Api::AuthController < ApplicationController
  def login
    user = User.find_by(email: params[:email])

    if user&.authenticate(params[:password])
      if user.driver? && user.status != "active"
        return render json: { error: "Driver not approved yet" }, status: :forbidden
      end

      render json: {
        message: "Login successful",
        user: {
          id: user.id,
          name: user.name,
          role: user.role,
          status: user.status
        }
      }
    else
      render json: { error: "Invalid credentials" }, status: :unauthorized
    end
  end
end

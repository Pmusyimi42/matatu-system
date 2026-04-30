class Api::AuthController < ApplicationController
  skip_before_action :authenticate_user!, only: [:login]

  def login
    user = User.find_by(email: params[:email])

    unless user&.authenticate(params[:password])
      return render json: { error: "Invalid credentials" }, status: :unauthorized
    end

    if user.driver? && !user.active?
      return render json: { error: "Driver not approved yet" }, status: :forbidden
    end

    token = generate_token(user)

    render json: {
      message: "Login successful",
      token: token,
      user: {
        id: user.id,
        name: user.name,
        role: user.role,
        status: user.status
      }
    }
  end

  private

  def generate_token(user)
    payload = {
      user_id: user.id,
      company_id: user.company_id,
      exp: 24.hours.from_now.to_i
    }
    JWT.encode(payload, Rails.application.credentials.secret_key_base, "HS256")
  end
end


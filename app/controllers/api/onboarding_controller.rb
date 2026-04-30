class Api::OnboardingController < ApplicationController
  skip_before_action :authenticate_user!, only: [:signup]

  def signup
    # Step 1: Create company
    company = Company.new(company_params)

    unless company.save
      return render json: { errors: company.errors.full_messages }, status: :unprocessable_entity
    end

    # Step 2: Set tenant context for admin creation
    Current.company = company

    # Step 3: Create admin user
    admin = User.new(admin_params)
    admin.role = "admin"
    admin.status = "active"
    admin.company = company

    unless admin.save
      company.destroy # Rollback company if admin fails
      return render json: { errors: admin.errors.full_messages }, status: :unprocessable_entity
    end

    Current.company = nil

    # Step 4: Generate token and auto-login
    token = generate_token(admin)

    render json: {
      message: "Company and admin created successfully",
      token: token,
      company: {
        id: company.id,
        name: company.name
      },
      user: {
        id: admin.id,
        name: admin.name,
        email: admin.email,
        role: admin.role
      }
    }, status: :created
  end

  private

  def company_params
    params.require(:company).permit(:name)
  end

  def admin_params
    params.require(:admin).permit(:name, :email, :password, :password_confirmation)
  end

  def generate_token(user)
    payload = {
      user_id: user.id,
      company_id: user.company_id,
      exp: 24.hours.from_now.to_i
    }
    JWT.encode(payload, Rails.application.credentials.secret_key_base, "HS256")
  end
end


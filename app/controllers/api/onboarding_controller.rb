class Api::OnboardingController < ApplicationController
  skip_before_action :authenticate_user!, only: [:signup]
  skip_before_action :check_setup_complete, only: [:signup]

  def signup
    company = nil
    admin = nil

    ActiveRecord::Base.transaction do
      company = Company.create!(company_params)
      Current.company = company

      admin = User.new(admin_params)
      admin.role = "admin"
      admin.status = "active"
      admin.company = company
      admin.save!
    end

    token = generate_token(admin)
    Current.company = nil

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

  rescue ActiveRecord::RecordInvalid => e
    Current.company = nil
    render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
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
      exp: 7.days.from_now.to_i
    }
    JWT.encode(payload, Rails.application.credentials.secret_key_base, "HS256")
  end
end

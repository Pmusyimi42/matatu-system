class Api::UsersController < ApplicationController
  before_action :require_admin, only: [:create]

  skip_before_action :check_setup_complete, only: [:create], if: :first_driver?

  def index
    users = Current.company.users
    render json: users
  end

  def show
    user = Current.company.users.find(params[:id])
    render json: user
  rescue ActiveRecord::RecordNotFound
    render json: { error: "User not found" }, status: :not_found
  end

  def me
    render json: Current.user
  end

  def create
    user = Current.company.users.new(user_params)

    if user.save
      render json: user, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(
      :name,
      :email,
      :password,
      :password_confirmation,
      :role,
      :status
    )
  end

  def require_admin
    unless Current.user&.admin?
      render json: { error: "Admin access required" }, status: :forbidden
    end
  end

  def first_driver?
    !Current.company&.users&.where(role: "driver")&.exists?
  end
end

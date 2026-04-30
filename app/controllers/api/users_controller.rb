class Api::UsersController < ApplicationController
  before_action :require_admin, only: [:create]

  # Allow first driver creation during setup
  skip_before_action :check_setup_complete, only: [:create], if: :first_driver?

  # GET /api/users
  def index
    users = Current.company.users
    render json: users
  end

  # GET /api/users/:id
  def show
    user = Current.company.users.find(params[:id])
    render json: user
  end

  # ✅ GET /api/users/me  (VERY IMPORTANT FOR FRONTEND)
  def me
    render json: Current.user
  end

  # POST /api/users
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

  # Allow system bootstrap (first driver)
  def first_driver?
    !Current.company&.users&.where(role: "driver")&.exists?
  end
end


# app/controllers/application_controller.rb
class ApplicationController < ActionController::API
  before_action :authenticate_user!
  before_action :set_current_context
  before_action :check_setup_complete, unless: :setup_controller?

  private

  def authenticate_user!
    header = request.headers["Authorization"]
    token = header&.split(" ")&.last

    return render json: { error: "Missing token" }, status: :unauthorized unless token

    begin
      payload = JWT.decode(token, Rails.application.credentials.secret_key_base, true, algorithm: "HS256").first
      @current_user = User.find(payload["user_id"])
    rescue JWT::ExpiredSignature
      render json: { error: "Token expired" }, status: :unauthorized
    rescue JWT::DecodeError, ActiveRecord::RecordNotFound
      render json: { error: "Invalid token" }, status: :unauthorized
    end
  end

  def current_user
    @current_user
  end

  def set_current_context
    Current.user = current_user
    Current.company = current_user&.company
  end

  def check_setup_complete
    return if Current.user&.admin? && request.path.include?("setup")
    return if Current.company&.setup_complete?

    render json: {
      error: "Setup incomplete",
      progress: Current.company&.setup_progress
    }, status: :forbidden
  end

  def setup_controller?
    controller_name == "onboarding" || request.path.include?("setup")
  end
end


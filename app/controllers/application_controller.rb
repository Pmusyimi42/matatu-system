class ApplicationController < ActionController::API
  before_action :authenticate_user!
  before_action :set_current_context

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
end


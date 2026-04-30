class ApplicationController < ActionController::API
  
  before_action :authenticate_user!
  before_action :set_current_context
  before_action :check_setup_complete, unless: :setup_action? 

  private

  # ========================
  # AUTHENTICATION (JWT)
  # ========================
  def authenticate_user!
    header = request.headers["Authorization"]
    token = header&.split(" ")&.last

    return render json: { error: "Missing token" }, status: :unauthorized unless token

    begin
      payload = JWT.decode(
        token,
        Rails.application.credentials.secret_key_base,
        true,
        algorithm: "HS256"
      ).first

      @current_user = User.find(payload["user_id"])

    rescue JWT::ExpiredSignature
      return render json: { error: "Token expired" }, status: :unauthorized

    rescue JWT::DecodeError, ActiveRecord::RecordNotFound
      return render json: { error: "Invalid token" }, status: :unauthorized
    end
  end

  def current_user
    @current_user
  end

  # ========================
  # TENANT CONTEXT (SAAS CORE)
  # ========================
  def set_current_context
    Current.user = current_user
    Current.company = current_user&.company
  end

  # ========================
  # SETUP GUARD (ONBOARDING FLOW)
  # ========================
  def check_setup_complete
    return if Current.company&.setup_complete?

    render json: {
      error: "Setup incomplete",
      progress: Current.company&.setup_progress
    }, status: :forbidden
  end

  def setup_action?
    # Exempt onboarding controller and setup paths
    return true if controller_name == "onboarding"
    return true if request.path.include?("setup")

    # Allow creating first vehicle/route/driver during setup
    return false unless %w[vehicles routes users].include?(controller_name)
    return false unless action_name == "create"

    !company_has_resource?(controller_name)
  end

  def company_has_resource?(resource_name)
    return false unless Current.company

    case resource_name
    when "vehicles" then Current.company.vehicles.any?
    when "routes" then Current.company.routes.any?
    when "users" then Current.company.users.where(role: "driver").any?
    else false
    end
  end

  # ========================
  # POLICY ENFORCEMENT (SAAS SECURITY LAYER)
  # ========================
  def authorize!(record, action = action_name)
    policy_class_name = "#{record.class}Policy"

    unless Object.const_defined?(policy_class_name)
      return render json: { error: "Policy not defined" }, status: :forbidden
    end

    policy = policy_class_name.constantize.new(Current.user, record)

    unless policy.public_send("#{action}?")
      render json: { error: "Unauthorized" }, status: :forbidden
    end
  end

  def policy(record)
    "#{record.class}Policy".constantize.new(Current.user, record)
  end
end



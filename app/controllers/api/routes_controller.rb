class Api::RoutesController < ApplicationController
  before_action :require_admin, only: [:create]

  def index
    routes = Current.company.routes
    render json: routes
  end

  def create
    route = Current.company.routes.new(route_params)

    if route.save
      render json: route, status: :created
    else
      render json: route.errors, status: :unprocessable_entity
    end
  end

  private

  def route_params
    params.require(:route).permit(:origin, :destination)
  end

  def require_admin
    unless Current.user&.admin?
      render json: { error: "Admin access required" }, status: :forbidden
    end
  end
end

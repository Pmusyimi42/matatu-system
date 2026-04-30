class Api::RoutesController < ApplicationController
  def index
    routes = Route.all
    render json: routes
  end

  def create
    route = Route.new(route_params)

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
end


module Api
  class TripLifecycleController < ApplicationController
    before_action :set_trip

    # POST /api/trips/:id/start
    def start
      service.start!
      render json: { message: "Trip started", trip: @trip }
    end

    # POST /api/trips/:id/end
    def end
      service.end!(cash_collected: params[:cash_collected])
      render json: { message: "Trip ended", trip: @trip }
    end

    # POST /api/trips/:id/close
    def close
      service.close!
      render json: { message: "Trip closed", trip: @trip }
    end

    private

    def set_trip
      @trip = Current.company.trips.find(params[:id])
    end

    def service
      @service ||= Trips::LifecycleService.new(@trip)
    end
  end
end

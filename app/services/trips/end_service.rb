module Trips
  class EndService
    def initialize(company:, trip:, params:)
      @company = company
      @trip = trip
      @params = params
    end

    def call
  raise StandardError, "Photo required" if @params[:cash_proof_photo].blank?

  @trip.complete_trip!(
    cash_collected: @params[:cash_collected],
    cash_proof_photo: @params[:cash_proof_photo]
  )

  @trip
end
  end
end

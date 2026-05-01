class Api::HealthController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index]
  skip_before_action :check_setup_complete, only: [:index]

  def index
    render json: { status: "ok", time: Time.current }
  end
end

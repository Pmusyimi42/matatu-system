class Api::BillingController < ApplicationController
  before_action :require_admin, only: [:invoice, :company_summary]
  before_action :set_month

  def invoice
    service = BillingService.new(company: Current.company, month: @month)
    render json: service.generate_invoice
  end

  def driver_statements
    if Current.user.admin?
      service = BillingService.new(company: Current.company, month: @month)
      render json: service.driver_statements
    else
      service = BillingService.new(company: Current.company, month: @month)
      statement = service.driver_statements.find { |s| s[:driver_id] == Current.user.id }

      if statement
        render json: statement
      else
        render json: { error: "No statement found" }, status: :not_found
      end
    end
  end

  def company_summary
    service = BillingService.new(company: Current.company, month: @month)
    render json: service.generate_invoice[:totals]
  end

  private

  def set_month
    @month = if params[:year] && params[:month]
      Time.zone.local(params[:year].to_i, params[:month].to_i)
    else
      Time.current.beginning_of_month
    end
  end

  def require_admin
    unless Current.user&.admin?
      render json: { error: "Admin access required" }, status: :forbidden
    end
  end
end

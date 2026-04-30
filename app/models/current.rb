class Current < ActiveSupport::CurrentAttributes
  attribute :user, :company

  def self.company!
    company or raise TenantMissingError, "Current.company not set in tenant context"
  end
end

class TenantMissingError < StandardError; end


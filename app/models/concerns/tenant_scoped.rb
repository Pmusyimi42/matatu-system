module TenantScoped
  extend ActiveSupport::Concern

  included do
    belongs_to :company
    validates :company_id, presence: true
    scope :for_company, ->(company) { where(company_id: company.id) }
  end

  private

  def assign_company
    self.company_id ||= Current.company&.id
  end
end

module TenantScoped
  extend ActiveSupport::Concern

  included do
    belongs_to :company

    validates :company_id, presence: true

    default_scope -> {
      raise "❌ Current.company not set" unless Current.company
      where(company_id: Current.company.id)
    }

    before_validation :assign_company
    before_save :ensure_company_matches
  end

  class_methods do
    def unscoped(*)
      raise "❌ Unsafe: unscoped is disabled in multi-tenant mode"
    end
  end

  private

  def assign_company
    self.company_id ||= Current.company!.id
  end

  def ensure_company_matches
    return unless will_save_change_to_company_id? || company_id.present?

    if company_id != Current.company!.id
      errors.add(:company_id, "does not match current tenant")
      throw(:abort)
    end
  end
end

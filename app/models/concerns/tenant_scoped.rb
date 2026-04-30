module TenantScoped
  extend ActiveSupport::Concern

  included do
    belongs_to :company
    validates :company_id, presence: true

    # =========================
    # SAFE default_scope
    # =========================
    # Never crash background jobs, console, or ActiveStorage
    default_scope -> {
      if Current.company.present?
        where(company_id: Current.company.id)
      else
        all
      end
    }

    before_validation :assign_company
    before_save :ensure_company_matches
  end

  private

  # =========================
  # Assign company safely
  # =========================
  def assign_company
    return unless Current.company

    self.company_id ||= Current.company.id
  end

  # =========================
  # Ensure tenant integrity
  # =========================
  def ensure_company_matches
    return unless Current.company

    if company_id.present? && company_id != Current.company.id
      errors.add(:company_id, "does not match current tenant")
      throw(:abort)
    end
  end
end

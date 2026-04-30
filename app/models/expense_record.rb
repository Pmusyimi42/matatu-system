class ExpenseRecord < ApplicationRecord
  include TenantScoped

  belongs_to :trip

  validates :description, presence: true
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validate :trip_must_be_active
  validate :trip_belongs_to_current_company

  private

  def assign_company
    self.company_id ||= trip&.company_id || Current.company&.id
  end

  def trip_must_be_active
    return if trip&.active?

    errors.add(:base, "Cannot add expense to a completed trip")
  end

  def trip_belongs_to_current_company
    return unless trip && Current.company

    if trip.company_id != Current.company.id
      errors.add(:trip, "does not belong to your company")
    end
  end
end

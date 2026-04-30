class ExpenseRecord < ApplicationRecord
  include TenantScoped

  belongs_to :trip

  validates :description, presence: true
  validates :amount, presence: true
  validate :trip_must_be_active
  validate :trip_belongs_to_current_company

  private

  def trip_must_be_active
    return if trip&.active?

    errors.add(:base, "Cannot add expense to a completed trip")
  end

  def trip_belongs_to_current_company
    return unless trip

    if trip.company_id != Current.company!.id
      errors.add(:trip, "does not belong to your company")
    end
  end

  def assign_company
    self.company_id ||= trip&.company_id || Current.company!.id
  end
end

